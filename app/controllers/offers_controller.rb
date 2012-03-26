class OffersController < ApplicationController
  def index
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def show
  end
  def latest
    @latest_offers = Offer.find(:all, :order => "id desc", :limit => 3).reverse
    render :partial => 'latest'
  end
end
