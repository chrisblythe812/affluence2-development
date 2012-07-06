class OffersController < ApplicationController
  def latest
    @latest_offers = Offer.latest
    render :partial => 'latest'
  end

  def index
    @featured_offers = Offer.where("featured = true", :order => 'created_at asc')
    @travel_offers = Offer.where("category like 'Travel'", :order => 'created_at asc')
    @services_offers = Offer.where("category like 'Services'", :order => 'created_at asc')
    @dinning_offers = Offer.where("category like 'Dinning'", :order => 'created_at asc')
    @shopping_offers = Offer.where("category like 'Shopping'", :order => 'created_at asc')
    @financial_offers = Offer.where("category like 'Financial'", :order => 'created_at asc')
  end

  def activate
    offer = Offer.find(params[:id])
    if current_user.plan == 'free'
      flash[:error] = "You need to Become a Premium Member to activate this offer"
      redirect_to offers_path and return
    end
    offer.promotion.activate_promotion_for_member(current_user)
    Activity.create_user_offer(current_user, offer)
    redirect_to offer.link
  end

  # will be called when free user tries to subscribe before offer activation.
  def confirm
    begin
      @result = Braintree::TransparentRedirect.confirm(request.query_string)
      if @result.success?
        current_user.update_user_with_plan_and_braintree_id(session[:user_plan], @result.customer.id)
        session[:user_plan]=nil
        flash[:success] = "You have successfully converted to paid member. Now you can activate to offer by clicking on the Activate button"
        redirect_to offers_path
      else
        flash[:error] = "Your payment was not success. Check your card information."
        redirect_to offers_path
      end
    rescue
      flash[:error] = "Your payment was not success. Check your card information."
      redirect_to offers_path
    end
  end


end
