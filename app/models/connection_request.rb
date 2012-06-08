class ConnectionRequest < ActiveRecord::Base
  belongs_to :requestor, :class_name => "User"
  belongs_to :requestee, :class_name => "User"

  validates :requestee_id, :uniqueness => { :scope => :requestor_id, :message => "Can only send on request per friend" }

  def self.present?(user, friend)
   connection_request = where(:requestor_id => user.id, :requestee_id => friend.id) +
    where(:requestor_id => friend.id, :requestee_id => user.id)
    return !connection_request.blank?
  end
end
