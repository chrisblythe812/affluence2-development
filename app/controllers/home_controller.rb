class HomeController < ApplicationController
before_filter :authenticate_user!, :only => :profile

  def index
  end

  def profile
   
  end
end
