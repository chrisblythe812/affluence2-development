class ActivitiesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @latest_activities = current_user.activities.page(params[:page]).per(3)
  end

  def latest
    if params["type"] == 'my Connections'
      @latest_activities = current_user.connections_activities(params["last_activity"])
    elsif params['type'] == 'profile'
      profile = Profile.find params['profile_id'].to_i
      @latest_activities = profile.user.activities_by_privacy_settings(current_user, params["last_activity"])
    else
      @latest_activities = Activity.all_by_privacy_setting(current_user, params["last_activity"])
    end
    render :partial => 'latest'
  end
end
 