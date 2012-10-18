class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_unread_messages_count, :if => :current_user?
  before_filter :persist_activity_in_session
  before_filter :set_cache_buster


  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.has_admin_access?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  def authenticate_paid_user!
    if current_user.plan == 'free'
      flash[:error] = "Unauthorized Access!
        Please become a premium member.
        #{ActionController::Base.helpers.link_to "Billing Info", edit_profile_path(current_user.permalink, :value => 'billing info')}".html_safe
      redirect_to(:back)
    end
  end

  def set_unread_messages_count
    session[:unread_messages_count] = current_user.unread_messages_counter
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || current_user_home_page
  end

  def current_user_home_page
    current_user.has_admin_access? ? '/admin' : '/home'
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

  def persist_activity_in_session
    init_activity_in_session
    check_activity_load_time_for("entire_network")
    check_activity_load_time_for("my_connections")
  end

  protected

  def check_activity_load_time_for(type)
    find_or_create_activity_in_session(type)

    if (session["activity"][type]["time"] != "")
      time_diff = (Time.now - Time.parse(session["activity"][type]["time"]))/60
      if time_diff > 10
        session["activity"][type]["ids"] = []
        session["activity"][type]["time"] = ""
      end
    end
  end

  def find_or_create_activity_in_session(type)
    if session["activity"][type].nil? || session["activity"][type]["ids"].blank?
      session["activity"][type] = {"ids" => [], "time" => ""}
    end
  end

  def init_activity_in_session
    session["activity"] = {} if session["activity"].nil?
  end

  def reset_session_activity
    session["activity"] = {}
  end
end
