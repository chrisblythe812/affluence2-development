class ActivitiesController < ApplicationController

  def index
    @latest_activities = Kaminari.paginate_array(Activity.all_by_privacy_setting).page(params[:page]).per(3)
  end

 def latest
    if params["my_connections"] == 'true'
      @latest_activities = current_user.connections_activities
    else
      @latest_activities = Activity.all_by_privacy_setting
    end
     render :partial => 'latest'
 end
end
 