class ConciergesController < ApplicationController
  before_filter :authenticate_user!


  def call
    @concierge = Concierge.find(params[:id])
    if current_user.plan == 'free'
      flash[:error] = "You need to Become a Premium Member to utilize the Concierge service"
      redirect_to profile_path(current_user.permalink) and return
    end


    if !current_user.profile.phone.blank? && @concierge.make_call(current_user)
    @concierge.promotion.activate_promotion_for_member(current_user)
    Activity.create_user_concierge(current_user, @concierge)
    #NotificationTracker.schedule_concierge_emails(current_user, @concierge)
    flash[:success]= 'Thank you for utilizing Concierge service'
    redirect_to profile_path(current_user.permalink)
    else
      flash[:success]= 'Please check your Mobile number that was registered with this account and try again '
      redirect_to profile_path(current_user.permalink)
    end

  end
end
