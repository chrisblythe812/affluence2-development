require 'spec_helper'

describe OfferController do

  describe "GET 'latest'" do
    it "returns http success" do
      get 'latest'
      response.should be_success
    end
  end

end
