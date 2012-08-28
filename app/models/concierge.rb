class Concierge < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy

  before_create :build_promotion

  def calls_count
    #promotion.promotions_users.count
    0
  end

  def make_call(user,mobile)
    account_sid = 'ACda525abca69de6bb2777e074da0ba91e'
    auth_token = '7a99e95167fce00419dcd90429ce14aa'
    @client = Twilio::REST::Client.new account_sid, auth_token
    begin
      @call = @client.account.calls.create(
          :from => number,
          :to => mobile,
          :url => 'http://example.com/call-handler'
      )
      return true
    rescue
     return false
    end
  end

end
