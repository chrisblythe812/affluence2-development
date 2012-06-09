class Connection < ActiveRecord::Base
  belongs_to :user, :touch => true                            #this is used for friends cache
  belongs_to :friend, :class_name => 'User', :touch => true   #this is used for friends cache

  validates :friend_id, :uniqueness => { :scope => :user_id, :message => "Same friend added twice" }

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
     connected = where(:user_id => user, :friend_id => friend)
    if connected.nil?
      connected = where(:user_id => friend, :friend_id => user)  
    end
    return connected.nil?
  end
end
