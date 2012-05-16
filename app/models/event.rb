class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_many :schedules, :dependent => :destroy
  has_many :includes, :dependent => :destroy




  scope :past, where('sale_ends_at <= ?', Date.today)
  scope :up_comming, where('sale_ends_at >= ?', Date.today)


  EMAIL_NOTIFICATIONS = {1 => 'registraion',
                 2 => 'schedule',
  }
  EMAIL_NOTIFICATION_METHODS = { 1 => 'event_registration',
                         2 => 'event_reminder',


  }
  EMAIL_REMINDER_SCHEDULE_INTERVAL_DAYS = [1,2] # days before the event starts

  accepts_nested_attributes_for :schedules, :includes


  validates_presence_of :title, :description, :price
  validates_presence_of :carousel_image, :normal_image, :on => :create
  validates :sale_ends_at, :presence => true
  validates :tickets, :presence => true


  has_permalink :title, :update => true


  attr_accessor :carousel_image, :normal_image


end
 