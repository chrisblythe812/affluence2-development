class EventsController < ApplicationController

  before_filter :authenticate_user!, :except => [:landing_page_events]
  before_filter :create_braintree_object, :only => [:index, :show, :home_page_events]

  #ssl_required :index,:show


  def index
    @profile_tab = false
    #@event_schedules = Event.up_comming.order("sale_ends_at DESC").select("id,start_date,title")
    @featured_events = Event.up_comming.featured.order("sale_ends_at DESC")
    @events = Event.up_comming.order("sale_ends_at DESC").page(params[:page]).per(3)
    @past_events = Event.past.limit(4).order("sale_ends_at DESC")
  end


  def show
    @profile_tab = false
    unless @event = Event.active.find_by_id(params[:id])
      flash[:notice]= "Event doesn't exists"
      redirect_to events_path
    end
  end


  def events_schedules
    @event_schedules = Event.up_comming.order("sale_ends_at DESC").select("id,start_date,title")
    render :layout => false
  end


  def register
    @event = Event.active.find(params[:id])
    if current_user.plan == 'free'
      flash[:error] = "You need to Become a Premium Member to register for this Event"
      redirect_to event_path(@event.id) and return
    end

    if @event.has_required_tickets?(params[:payable_promotion][:total_tickets].to_i)
    payable_promotion = PayablePromotion.create_event_promotion(params[:payable_promotion], @event, current_user)
    Event.process_tickets(@event, params[:payable_promotion], 'initial')
    if !payable_promotion.blank?
      result = BrainTreeTranscation.event_payment(payable_promotion)
      if result == 'success'
        Event.process_tickets(@event, params[:payable_promotion], 'success')
        @event.promotion.activate_promotion_for_member(current_user)
        Activity.create_user_event(current_user, @event)
        NotificationTracker.schedule_event_emails(current_user, @event)
        flash[:success]= 'Your have successfully registered for the event'
        redirect_to orders_path()
      elsif result == 'failed'
        Event.process_tickets(@event, params[:payable_promotion], 'failure')
        flash[:error]= 'Your event registration failed due to unsuccessful transaction'
        redirect_to event_path(@event.id)
      else
        flash[:error]= 'Your event registration failed due to unsuccessful transaction'
        #flash[:error]= @result.errors._inner_inspect
        redirect_to event_path(@event.id)
      end
    end
    elsif @event.has_tickets?
      flash[:error]= "You Can't register for the event with more than the available tickets"
      redirect_to event_path(@event.id)
    else
      flash[:error]= 'There are no more tickets available to register for this event'
      redirect_to event_path(@event.id)
    end

  end


  # will be called when free user tries to subscribe before event registration.
  def confirm
    @event = Event.active.find(params[:event_id])
    begin
      @result = Braintree::TransparentRedirect.confirm(request.query_string)
      if @result.success?
        current_user.update_user_with_plan_and_braintree_id(session[:user_plan], @result.customer.id)
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
    @promotion_events = Event.up_comming.limit(max).order("sale_ends_at DESC")
  end
end
