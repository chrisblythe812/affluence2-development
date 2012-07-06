class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_unread_messages_count, :if => :current_user?
  include SslRequirement

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.superadmin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  def authenticate_paid_user!
    if current_user.plan == 'free'
      flash[:error] = "Unauthorized Access!
        Please become a premium member.
        #{ActionController::Base.helpers.link_to "Billing Info", edit_profile_path(current_user.permalink, :value => 'billing info')}".html_safe
      redirect_to user_conversations_path(current_user)
      #      flash[:error] = "Unauthorized Access!  Please become a premium member."
      #      redirect_to profile_path(current_user.permalink)
    end
  end

  def set_unread_messages_count
    session[:unread_messages_count] = current_user.unread_messages_counter
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || current_user_home_page
  end

  def current_user_home_page
    current_user.superadmin? ? '/admin' : '/home'
  end

  def current_user?
    current_user
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
