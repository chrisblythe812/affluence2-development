class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_many :schedules, :dependent => :destroy
  has_many :includes, :dependent => :destroy




  EMAIL_NOTIFICATIONS = {1 => 'registraion',
                 2 => 'schedule',
  }

  EMAIL_NOTIFICATION_METHODS = { 1 => 'event_registration',
                         2 => 'event_reminder',


  }

  EMAIL_REMINDER_SCHEDULE_INTERVAL_DAYS = [1,2] # days before the event starts

  validates :sale_ends_at, :presence => true
  validates :tickets, :presence => true
end
 