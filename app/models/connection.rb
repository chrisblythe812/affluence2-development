class Connection < ActiveRecord::Base
  belongs_to :user, :touch => true                            #this is used for friends cache
  belongs_to :friend, :class_name => 'User', :touch => true   #this is used for friends cache

  validates :friend_id, :uniqueness => { :scope => :user_id, :message => "Same friend added twice" }

  attr_accessor :skip_observer
end
