class TwilioCallsController < ApplicationController
  
  def receive_call
    TwilioCall.create_call(params)
    #record create
    xml_format = Twilio::TwiML.build do |res|
      res.say    'Welcome to Affluence Concierge service', :voice => 'man'
      res.say    'We are forwading your call to our customer service. Please stay on line. Thank You', :voice => 'man'
      res.dial TWILIO[Rails.env]['support_number'], :record => true # needto add customer number
    end
    puts xml_format
    render :inline => xml_format
  end

  def status_call_back    
    TwilioCall.record_call(params)
    render :nothing => true
  end
end