class ActivitiesController < ApplicationController


  def latest
    @latest_activities = Activity.find(:all, :order => "id desc", :limit => 10)
    render :partial => 'latest'
  end
end
