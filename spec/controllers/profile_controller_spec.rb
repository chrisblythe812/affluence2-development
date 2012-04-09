require 'spec_helper'

describe ProfileController do
  include Devise::TestHelpers

  login_user

  after (:each) do
     User.where(:email=>'john+1@gmail.com').first.delete
  end
 describe "GET show" do
    it "returns a 200" do
      get :show, :id => @user.id
      response.should be_successful
    end
  end
end
