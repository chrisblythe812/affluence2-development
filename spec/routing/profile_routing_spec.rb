require 'spec_helper'

describe "routing to profile" do
  it "routes /profile/xxxxxxxx to profile#show" do
    { :get => "/profile/*" }.should route_to(
      :controller => "profile",
      :action => "show",
      :id => "*"
    )
  end
end

