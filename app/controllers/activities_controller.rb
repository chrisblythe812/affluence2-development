class ActivitiesController < ApplicationController


  def latest
    if params["my_connections"] == 'true'
      @latest_activities = current_user.connections_activities
    else
      @latest_activities = Activity.find(:all, :order => "id desc", :limit => 6)
  end
     render :partial => 'latest'
 end
end
 