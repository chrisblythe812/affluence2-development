class WelcomeController < ApplicationController
  layout "welcome"
  def index
    @latest_offers = Offer.find(:all, :order => "id desc", :limit => 4).reverse
    
  end
end
