require 'spec_helper'

describe "routing to offers" do
  it "routes /offers/latest to offers#latest" do
    { :get => "/offers/latest" }.should route_to(
      :controller => "offers",
      :action => "latest"
    )
  end
end









