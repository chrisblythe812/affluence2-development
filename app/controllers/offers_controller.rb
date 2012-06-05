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
  offer.promotion.activate_promotion_for_member(current_user)
  Activity.create_user_offer(current_user,offer)
  redirect_to offer.link
  end
end
