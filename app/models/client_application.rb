class ClientApplication < ActiveRecord::Base
  has_many :access_grants

  before_create :generate_keys

  private
  def generate_keys
    self.application_key, self.secret = SecureRandom.hex(16), SecureRandom.hex(16)
  end
end