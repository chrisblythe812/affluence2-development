class AccessGrant < ActiveRecord::Base
  belongs_to :user
  belongs_to :client_application

  def self.find_access(access_token)
    where(:token => access_token).first
    # any_of(
    # {:access_token_expires_at => nil},
    # {:access_token_expires_at.gt => Time.now}).first
  end

  before_create :gen_tokens, :update_expiration
  def self.prune!
    where('created_at <= ?',3.days.ago).delete_all
  end

  # def self.authenticate(client_application_id)
  # where(:client_application_id => client_application_id).first
  # end

  def start_expiry_period!
    # 60.days.from_now -- time issue
    self.update_attribute(:access_token_expires_at, 60.days.from_now)
  end

  def valid_token?
    self.token.present? && self.access_token_expires_at > DateTime.now
  end

  protected

  def gen_tokens
    self.token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16)
  end

  def update_expiration
    self.access_token_expires_at = 60.days.from_now
  end
end