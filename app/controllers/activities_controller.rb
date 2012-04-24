class ActivitiesController < ApplicationController


  def latest
    if params["my_connections"] == 'true'
      p "ssssssssssssssssssssssssssssssssssssssssssssssssssss"
      p  @latest_activities
      @latest_activities = current_user.connections_activities
    else
      @latest_activities = Activity.all_by_privacy_setting
      p "ddddddddddddddddddddddddddddddddddddddddddddddddddddd"
      p  @latest_activities
  end
     render :partial => 'latest'
 end
end
 