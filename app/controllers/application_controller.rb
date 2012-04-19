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
  def states_of_country
    begin
      render :json => Carmen::states(params[:country_code]).to_json
    rescue Carmen::StatesNotSupported, Carmen::NonexistentCountry
      render :json => [].to_json
    end
  end
  def resource_name
    :user
  end

  def resource
    current_user
  end

  def create_braintree_object
    if current_user.plan != 'free'
      current_user.with_braintree_data!
      @credit_card = current_user.default_credit_card
    end
  end



end
