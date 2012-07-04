require 'spec_helper'

describe RegistrationsController do

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @tr_data = Braintree::TransparentRedirect.
        create_customer_data(:redirect_url => 'http://localhost:3000/profile/confirm' )
  end



  context "Registration page" do
     render_views

    it "should be successful with https" do
      request.env['HTTPS'] = 'on'
      get :new
      response.should be_success
    end


    it "should display registration fields"  do
      request.env['HTTPS'] = 'on'
      visit new_user_registration_path
      page.should render_template('new')
      page.body.should include("https://sandbox.braintreegateway.com")

      bt_url = Braintree::TransparentRedirect.url
      page.should have_selector("form",
                                    :action =>  bt_url
                      )
      page.fill_in "user_profile_attributes_first_name", :with => "uma mahesh"
      page.fill_in "user_profile_attributes_first_name", :with => "seeram"
      #page.click_button 'Register'
      session[:user_info] = {"user"=>{"profile_attributes"=>{"first_name"=>"uma", "last_name"=>"seeram", "country"=>"India", "city"=>"kkd"}, "email"=>"dasda1111@sadfsa.mju", "password"=>"[FILTERED]", "password_confirmation"=>"[FILTERED]", "plan"=>"free"}}

      #session.stubs(:user_info).returns(session_values)

      #ApplicationController.stub(session[:user_info]).and_return(session_values)




      visit '/profile/confirm?http_status=200&id=jfm28vg6j7bqdpd8&kind=create_customer&hash=a98838848b208504072ea3f554a1e250a07a2c66'
    end


  end

end
