class ConciergesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_concierge_resource

  def authorize_concierge_resource
    begin
       authorize! :all, :concierge
    rescue CanCan::AccessDenied
      flash[:error] = "Concierge is restricted to premium members. Become a premium member.
          #{ActionController::Base.helpers.link_to "Register", edit_profile_path(current_user.permalink, :value => 'billing info')}".html_safe
        redirect_to(:back)
    end
  end

  def call
    @concierge = Concierge.find(params[:id])
    if params[:phone_number].blank?
      flash[:error] = "Please provide the correct phone number"
      redirect_to profile_path(current_user.permalink) and return
    end
    if !params[:phone_number].blank? && @concierge.make_call(current_user, params[:phone_number])
    @concierge.promotion.activate_promotion_for_member(current_user)
    Activity.create_user_concierge(current_user, @concierge)
    reset_session_activity
    #NotificationTracker.schedule_concierge_emails(current_user, @concierge)
    session["activity"] = nil
    flash[:success]= 'Thank you for utilizing Concierge service'
    redirect_to profile_path(current_user.permalink)
    else
      flash[:success]= 'Please check your Mobile number that was registered with this account and try again '
      redirect_to profile_path(current_user.permalink)
    end
  end
end
