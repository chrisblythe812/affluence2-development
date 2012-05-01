class EventsController < ApplicationController

  before_filter :authenticate_user!, :except => [:landing_page_events]
  before_filter :create_braintree_object, :only =>  [:index, :show, :home_page_events]

  #ssl_required :index,:show


  def index
    @profile_tab = false
    @events = Event.last(6)
  end


  def show
    @profile_tab = false
    @event = Event.find(params[:id])
  end


  def register
    @event = Event.find(params[:id])
    payable_promotion = PayablePromotion.create_event_promotion(params[:payable_promotion],@event,current_user)
    if !payable_promotion.blank?
      result = BrainTreeTranscation.event_payment(payable_promotion)
      if result == 'success'
        Activity.create_user_event(current_user,@event)
        NotificationTracker.schedule_event_emails(current_user,@event)
        flash[:success]= 'Your have successfully registered for the event'
        redirect_to orders_path()
      elsif result == 'failed'
        flash[:error]= 'Your event registration failed due to unsuccessful transaction'
        redirect_to event_path(@event.id)
      else
        flash[:error]= 'Your event registration failed due to unsuccessful transaction'
        #flash[:error]= @result.errors._inner_inspect
        redirect_to event_path(@event.id)
      end
    end

  end


  # will be called when free user tries to subscribe before event registration.
   def confirm
     @event = Event.find(params[:event_id])
     begin
     @result = Braintree::TransparentRedirect.confirm(request.query_string)
     if @result.success?
       current_user.update_user_with_plan_and_braintree_id(session[:user_plan],@result.customer.id)
       session[:user_plan]=nil
       flash[:success] = "You have successfully converted to paid member. Now you can register to event by clicking on the Register button"
       redirect_to event_path(@event.id)
     else
       render action: :show
     end
     rescue
       flash[:error] = "Your payment was not success. Check your card information."
       redirect_to event_path(@event.id)
     end
   end




  def home_page_events
    get_latest
    render :partial => 'home_page_events'
  end

  def landing_page_events
    get_latest
    render :partial => 'landing_page_events'
  end

  def get_latest(max=3)
    @promotion_events = Promotion.find_all_by_promotionable_type('Event', :limit => max)
  end
end
