class Connection < ActiveRecord::Base
  belongs_to :user, :touch => true                            #this is used for friends cache
  belongs_to :friend, :class_name => 'User', :touch => true   #this is used for friends cache

  validates :friend_id, :uniqueness => { :scope => :user_id, :message => "Same friend added twice" }

  attr_accessor :skip_observer

  def self.make_connection(user, friend)
     connected = where(:user_id => user.id, :friend_id => friend.id).first
    if connected.blank?
      connected = create(:user_id => user.id, :friend_id => friend.id)
      NotificationTracker.create(:user_id => user.id, :channel => 'email', :subject => "Connection",
        :status => 'pending', :notifiable_id => connected.id, :notifiable_type => 'Connection',
        :notifiable_mode => 1, :scheduled_date => Date.today)
    end
    return connected

  end


end
