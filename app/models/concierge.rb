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
    account_sid = TWILIO[Rails.env]['account_sid']
    auth_token = TWILIO[Rails.env]['auth_token']
    @client = Twilio::REST::Client.new account_sid, auth_token
    begin
      @call = @client.account.calls.create(
      :from => TWILIO[Rails.env]['twilio_number'],
      :to => mobile,
      :url => TWILIO[Rails.env]['call_back_url'] + "?" + "user=#{user.id}",
      :method => :get,
      :StatusCallback => TWILIO[Rails.env]['status_call_back_url'], 
	    :StatusCallbackMethod => :get,
	    :Record => true
      )
      return true
    rescue
     return false
    end
  end

end
