class HomeController < ApplicationController
before_filter :authenticate_user!, :only => :profile

  def index
  end

  def profile
   
  end

  def latest_members
  
    @latest_members = User.find(:all, :order => "id desc", :limit => 5).reverse

       render :partial => 'latest_members'
 
  end
end
