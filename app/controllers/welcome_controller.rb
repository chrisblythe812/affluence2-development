class WelcomeController < ApplicationController
  layout "welcome"

  def index
    @latest_offers = Offer.latest(4)
  end

  def receive_call
    #puts params.inspect
    #record create
	  xml_format = Twilio::TwiML.build do |res|
	  res.say    'Welcome to Affluence Concierge service', :voice => 'man'
	  res.say    'We are forwading your call to our customer service. Please stay on line. Thank You', :voice => 'man'
    res.dial '+919866439593', :record => true # needto add customer number
	 end
     puts xml_format
     render :inline => xml_format
  end

def status_call_back
#record update
#puts params.inspect
end

end
 
