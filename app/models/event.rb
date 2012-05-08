class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_many :schedules, :dependent => :destroy
  has_many :includes, :dependent => :destroy


  scope :past, where('sale_ends_at <= ?', Date.today)


  EMAIL_NOTIFICATIONS = {1 => 'registraion',
                 2 => 'schedule',
  }
  EMAIL_NOTIFICATION_METHODS = { 1 => 'event_registration',
                         2 => 'event_reminder',


  }
  EMAIL_REMINDER_SCHEDULE_INTERVAL_DAYS = [1,2] # days before the event starts

  accepts_nested_attributes_for :schedules

  validates_presence_of :title, :description, :price
  validates :sale_ends_at, :presence => true
  validates :tickets, :presence => true

  has_permalink :title, :update => true

  after_create :create_promotion_with_images
  after_update :update_image

  attr_accessor :image, :time

  def create_promotion_with_images
    self.build_promotion
    set_start_date
    save
    create_image
  end

  def update_image
   if !self.image.blank?
      img = promotion.photos.first
      if !img.blank?
        img.update_attributes(:image => self.image)
      else
        create_image
      end
    end
   end

    def create_image
      photo = {
          title: self.title,
          description: self.description,
          image: self.image
      }
      promotion.photos.build(photo)
      promotion.save
    end

   def set_start_date
     self.start_date = self.schedules.first.date.to_date unless  self.schedules
   end

end
 