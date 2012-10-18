class ActivitiesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @latest_activities = current_user.activities.page(params[:page]).per(3)
  end

  def latest
    init_activity_in_session

    if params["type"] == 'my Connections'
      get_my_connections_activities
    elsif params['type'] == 'profile'
      profile = Profile.find params['profile_id'].to_i

      check_activity_load_time_for(profile.user.email)
      if !session["activity"][profile.user.email]["ids"].blank? && params["last_activity"].nil?
        get_activities_of(profile.user.email)
      else
          @latest_activities = profile.user.activities_by_privacy_settings(current_user, params["last_activity"])
      end
      update_session_activities_id_of(profile.user.email)
    else
      get_entire_network_activities
    end
    render :partial => 'latest'
  end

  private

  def get_entire_network_activities
    if !session["activity"]["entire_network"]["ids"].blank? && params["last_activity"].nil?
      get_activities_of("entire_network")
    else
      @latest_activities = Activity.all_by_privacy_setting(current_user, params["last_activity"])
      update_session_activities_id_of("entire_network")
    end
  end

  def get_my_connections_activities
    if !session["activity"]["my_connections"]["ids"].blank? && params["last_activity"].nil?
      get_activities_of("my_connections")
    else
      @latest_activities = current_user.connections_activities(params["last_activity"])
      update_session_activities_id_of("my_connections")
    end
  end

  def get_activities_of(type)
    @latest_activities = Activity.find(session["activity"][type]["ids"])
    @latest_activities.reverse!
  end

  def update_session_activities_id_of(type)
    @latest_activities.each do |activity|
      session["activity"][type]["ids"] << activity.id
      session["activity"][type]["time"] = Time.now.strftime("%Y %B %d, %H:%M")
    end
    session["activity"][type]["ids"].uniq!
  end
end
 