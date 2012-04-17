require 'spec_helper'

describe ProfilesController do
  include Devise::TestHelpers

  login_user
  

 describe "GET show" do
    it "returns a 200" do
      get :show, :id => @user.id
      response.should be_successful
    end
  end
 describe "GET update" do
    before(:each) do 
      @profile = FactoryGirl.create(:profile)
    end

    it "should redirect to show" do
      @profile.update_attributes({:city=>"hyd"}).should be true
      post :update, :id => @profile.id, :profile => {}

      flash[:notice].should eql 'Profile was successfully updated.'
      response.should redirect_to(profile_url(@profile))
     end
    it "should redirect to edit" do
      @profile.update_attributes({:city=>"hyd", :first_name => ''}).should be false
      post :update, :id => @profile.id, :profile => {:first_name => ''}
  
     p  @profile.errors
 
      @profile.should have(1).errors_on(:first_name)
      response.should render_template('edit')
     end
  end
end
