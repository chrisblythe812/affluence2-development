require 'spec_helper'

describe OffersController do
  before(:all) do
    (1..10).collect do |x|
       offer = FactoryGirl.create(:offer, :title => "offer"+x.to_s)
       FactoryGirl.create(:photo,
                  :image => Rails.root.join('app', 'assets', 'images', 'events-1.jpg'),
                  :photoable => offer)
    end
  end

  describe "GET 'latest'" do
  it "returns http success" do
      @latest_offers = Offer.last(3)
      @latest_offers.size.should == 3

      xhr :get, :latest
      response.should render_template("latest")
    end
  end
end
