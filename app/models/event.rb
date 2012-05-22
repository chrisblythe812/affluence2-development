class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_many :schedules, :dependent => :destroy
  has_many :includes, :dependent => :destroy



  scope :active, where(:status => true)
  scope :draft, where(:status => false)

  scope :past, where('sale_ends_at <= ?', Date.today)
  scope :up_comming, where('sale_ends_at >= ?', Date.today)


  EMAIL_NOTIFICATIONS = {1 => 'registraion',
                 2 => 'schedule',
  }
  EMAIL_NOTIFICATION_METHODS = { 1 => 'event_registration',
                         2 => 'event_reminder',


  }
  EMAIL_REMINDER_SCHEDULE_INTERVAL_DAYS = [1,2] # days before the event starts

  accepts_nested_attributes_for :schedules, :includes, :promotion

  before_validation :set_start_date
  validates_presence_of :title, :description, :price
#  validates_presence_of :carousel_image, :normal_image, :on => :create
  validates :sale_ends_at, :presence => true
  validates :tickets, :presence => true
  validate :compare_with_start_date

  has_permalink :title, :update => true


  attr_accessor :carousel_image, :normal_image

  private
  def set_start_date
    self.start_date = self.schedules.first.date.to_date
  end

  def compare_with_start_date
    self.errors = "'sale end' date should be before 'event start' date" unless self.start_date >= self.sale_ends_at
  end
end
  