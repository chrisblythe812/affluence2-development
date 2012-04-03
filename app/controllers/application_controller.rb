class ApplicationController < ActionController::Base
  protect_from_forgery
  include SslRequirement
  
  def authenticate_admin_user!
    authenticate_user!
    unless current_user.superadmin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || '/home'
  end

  def set_profile_navigation
    @profile_navigation = true
  end

end
