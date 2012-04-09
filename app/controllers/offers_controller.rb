class OffersController < ApplicationController
  def latest
    @latest_offers = Offer.latest
    render :partial => 'latest'
  end
end
