class ConnectionRequest < ActiveRecord::Base
  belongs_to :requestor, :class_name => "User"
  belongs_to :requestee, :class_name => "User"

  validates :requestee_id, :uniqueness => { :scope => :requestor_id, :message => "Can only send on request per friend" }
end
