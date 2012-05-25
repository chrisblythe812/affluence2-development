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
end
