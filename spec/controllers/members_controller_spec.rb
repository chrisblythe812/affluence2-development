require 'spec_helper'
  
describe MembersController do
         login_user
 
  describe "GET 'latest'" do
    it "returns http success" do
      (1..10).collect{ |x| FactoryGirl.create(:user, :email => "david+#{x}@gmail.com")}
      @latest_members = User.members.last(3)
      @latest_members.size.should == 3
      
      
      xhr :get, :latest
      response.should render_template("latest")
    end
  end
  describe "GET index" do
    it "returns a 200" do
      get :index
      response.should be_successful
    end
  end

end
 