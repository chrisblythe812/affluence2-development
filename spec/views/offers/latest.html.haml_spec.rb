require 'spec_helper'

describe "offers/_latest.html.haml" do
  it "renders _latest partial" do
    @offers = (1..10).collect{ FactoryGirl.create(:offer)}
    latest_offers = Offer.latest
    latest_offers.should have(3).entries  
  

  render  :partial => "latest", :collection => @latest_offers
  rendered.should =~ /directly rendered/

  #    view.should render_template(:partial => "latest", :collection => @latest_offers)
end

pending "add some examples to (or delete) #{__FILE__}"
end
