class WelcomeController < ApplicationController
  layout "welcome"

  def index
    @latest_offers = Offer.latest(4)

  end
end
 