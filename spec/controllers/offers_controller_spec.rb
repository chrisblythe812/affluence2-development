require 'spec_helper'

describe OffersController do

 describe "GET 'latest'" do
  it "returns http success" do
      @latest_offers = Offer.last(3)
      @latest_offers.size.should == 3

      xhr :get, :latest
      response.should render_template("latest")
    end
  end
end
     