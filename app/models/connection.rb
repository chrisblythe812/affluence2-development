class Connection < ActiveRecord::Base
  belongs_to :user, :touch => true #this is used for friends cache
  belongs_to :friend, :class_name => 'User', :touch => true #this is used for friends cache
  has_one :activity, :as => :resource
  validates :friend_id, :uniqueness => {:scope => :user_id, :message => "Same friend added twice"}

  attr_accessor :skip_observer

  def self.make_connection(user, friend)
    connected = create(:user_id => user.id, :friend_id => friend.id)
    connected = create(:user_id => friend.id, :friend_id => user.id)
    NotificationTracker.create(:user_id => user.id, :channel => 'email', :subject => "Connection",
                               :status => 'pending', :notifiable_id => connected.id, :notifiable_type => 'Connection',
                               :notifiable_mode => 1, :scheduled_date => Date.today)
    return connected
  end

  def notify_user_through_email
    NotificationTracker.create(:user_id => self.user_id, :channel => 'email', :subject => "Connection",
                               :status => 'pending', :notifiable_id => self.id, :notifiable_type => 'Connection',
                               :notifiable_mode => 1, :scheduled_date => Date.today)
  end

  def self.are_connected?(user, friend)
    where("(user_id=? and friend_id=?) or (user_id=? and friend_id=?)",user, friend,friend,user).count > 0
  end
end
