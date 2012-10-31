class TwilioCall < ActiveRecord::Base

  belongs_to :user
  
  def self.create_call(params)
    twilio_call = self.new(:user_id => params[:user], :account_sid => params[:AccountSid],
    :direction => params[:Direction], :call_sid =>  params[:CallSid],
    :from_phone_number => params[:From], :from_country => params[:FromCountry],
    :call_status => params[:CallStatus], :to_phone_number => params[:To],
    :to_country => params[:ToCountry], :api_version =>  params[:ApiVersion])

    twilio_call.save!
  end

  def self.record_call(params)
    twilio_call = TwilioCall.find_by_call_sid(params[:CallSid])
    if twilio_call
      twilio_call.update_attributes(:call_status => params[:CallStatus], :recording_url => params[:RecordingUrl],
      :call_duration => params[:CallDuration], :recording_duration => params[:RecordingDuration],
      :recording_sid => params[:RecordingSid])
    end
  end

end