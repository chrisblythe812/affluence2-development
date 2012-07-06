require 'spec_helper'


describe "registrations/new.html.erb" do

  before(:each) do
     @user = Factory.build(:user)
     @view.should_receive(:resource).and_return(User.new)
     @tr_data = Braintree::TransparentRedirect.
         create_customer_data(:redirect_url => 'http://localhost:3000/profile/confirm' )
    @bt_url = Braintree::TransparentRedirect.url
  end

  it "Display registration page with form submition to braintree and has filed with tr_data" do
    render :template => "registrations/new", :handlers => [:haml] ,:formats => [:html]

    rendered.should have_selector("form",
                    :action =>  @bt_url
                    )

    rendered.should have_selector("form" ) do |form|
      form.should have_selector(
                      "input[type=hidden]" ,
                      :name => "tr_data",
                      :value => @tr_data
                  )


    end

  end
end
