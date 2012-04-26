class EventsController < ApplicationController

  before_filter :authenticate_user!, :except => [:landing_page_events]
  before_filter :create_braintree_object, :only =>  [:index, :show, :home_page_events]

  #ssl_required :index,:show


  def index
    @profile_tab = false
    @events = Event.all
  end


  def show
    @profile_tab = false
    @event = Event.find(params[:id])
  end


  def register
    @event = Event.find(params[:id])
    @payable_promotion = PayablePromotion.new(params[:payable_promotion])
    @payable_promotion.price_per_ticket = @event.price
    @payable_promotion.user_id = current_user.id
    @payable_promotion.promotion_id = @event.promotion.id
    @payable_promotion.total_amount = calculate_total_amount(params[:payable_promotion][:total_tickets],@event.price)

    if @payable_promotion.save
      result = BrainTreeTranscation.event_payment(@payable_promotion)
      if result == 'success'
        Activity.create_user_event(current_user,@event)
        NotificationTracker.event_notification_on_successful_registration(current_user,@event)
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


  def calculate_total_amount(total_tickets,price_per_ticket,discount=nil)
    total_amount = 0
    if !total_tickets.blank?
      total_amount = price_per_ticket*total_tickets.to_i
    end
    #todo add code for discounts
    total_amount
  end


  #def create_braintree_object
    #if current_user.plan == 'free'
     # @tr_data = Braintree::TransparentRedirect.
          #create_customer_data(:redirect_url => confirm_events_url())
    #else
     # current_user.with_braintree_data!
    #end
  #end

   def confirm
     @event = Event.find(params[:event_id])
     begin
     @result = Braintree::TransparentRedirect.confirm(request.query_string)
     if @result.success?
       current_user.plan = session[:user_plan]
       current_user.braintree_customer_id = @result.customer.id
       current_user.save
       session[:user_plan]=nil
       SubscriptionFeeTracker.create(:user_id => current_user.id,:renewal_date => Date.today, :amount => current_user.plan_amount )
       redirect_to event_path(@event.id)
     else
       #flash[:notice]= @result.errors._inner_inspect
       #redirect_to event_path(@event.id)
       render action: :show
     end
     rescue
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
