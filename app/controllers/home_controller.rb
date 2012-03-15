class HomeController < ApplicationController
#before_filter :authenticate_user!, :only => :profile
  layout "welcome"

  def index
  end

  def profile
   
  end
end
