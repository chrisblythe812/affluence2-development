class Concierge < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy

  before_create :build_promotion

  def calls_count
    #promotion.promotions_users.count
    0
  end

  def self.get_latest_config
  if Concierge.last.blank?
    Concierge.create(:title=>' test',:description=>'test',:number=>'9932332123')
  else
    Concierge.last
  end
  end

  def make_call(user,mobile)
    account_sid = 'ACda525abca69de6bb2777e074da0ba91e'
    auth_token = '7a99e95167fce00419dcd90429ce14aa'
    # account_sid = 'AC928413696ead2152b78129be097cc931'
    # auth_token = '52f08792895fe31eb27fe28c918c80b7'
    @client = Twilio::REST::Client.new account_sid, auth_token
    begin
      @call = @client.account.calls.create(
      # :from => "+14155992671",
      :from =>"+1541-516-1631",
      :to => mobile,
      # :url => "http://web1.tunnlr.com:12609/twilio_calls/receive_call?user=#{user.id}", # local dev url
      # :url => "https://affluence2-staging.herokuapp.com/twilio_calls/receive_call?user=#{user.id}", # staging url
      :url => "https://affluence2-development.herokuapp.com/twilio_calls/receive_call?user=#{user.id}",    
      :method => :get,
      # :StatusCallback => "http://web1.tunnlr.com:12609/twilio_calls/status_call_back", # local url
      # :StatusCallback => "https://affluence2-staging.herokuapp.com/twilio_calls/status_call_back", # staging url
	    :StatusCallback => "https://affluence2-development.herokuapp.com/twilio_calls/status_call_back",
	    :StatusCallbackMethod => :get,
	    :Record => true
      )
      return true
    rescue
     return false
    end
  end

end
