class HomeController < ApplicationController
 before_filter :authenticate_user!, :set_profile_navigation


  def index

  end


end
