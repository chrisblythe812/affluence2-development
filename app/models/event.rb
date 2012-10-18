class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_many :schedules, :dependent => :destroy, :order => "date asc"
  has_many :includes, :dependent => :destroy


  scope :active, where(:status => true)
  scope :draft, where(:status => false)

  scope :past, where('status = ?  and sale_ends_at <= ?', true, Date.today)
  scope :up_comming, where('status = ?  and sale_ends_at >= ?', true, Date.today)

  scope :featured, where('status = ?  and featured = ?', true, true)


  EMAIL_NOTIFICATIONS = {1 => 'registraion',
                         2 => 'schedule',
  }
  EMAIL_NOTIFICATION_METHODS = {1 => 'event_registration',
                                2 => 'event_reminder',


  }
  EMAIL_REMINDER_SCHEDULE_INTERVAL_DAYS = [1, 2] # days before the event starts

  accepts_nested_attributes_for :schedules, :includes, :promotion

  #before_validation :set_start_date
  validates_presence_of :title, :description, :price
  validates_presence_of :carousel_image, :normal_image, :on => :create
  validates :sale_ends_at, :presence => true
  validates :tickets, :presence => true
  #validate :compare_with_start_date

  has_permalink :title, :update => true


  attr_accessor :carousel_image, :normal_image


  #private


  #def set_start_date
  #self.start_date = self.schedules.first.date.to_date
  #end

  def has_tickets?
    (!tickets_remaining.blank?) && (tickets_remaining.to_i > 0)
  end

  def has_required_tickets?(required_tickets)
    has_tickets? && (tickets_remaining >= required_tickets)
  end

  def has_more_than_10_tickets?
    has_tickets? && tickets_remaining > 10
  end

  def has_gallery?
    promotion.gallery_images.blank?
  end

  def self.process_tickets(event, payable_promotion, state)
    if state == 'initial'
      initial_process(event, payable_promotion)
    elsif state == 'success'
      success_process(event, payable_promotion)
    elsif state == 'failure'
      failure_process(event, payable_promotion)
    end
  end


  def self.initial_process(event, payable_promotion)
    event = Event.find(event.id)
      if event.tickets_remaining > 0 && event.tickets_remaining.to_i >= payable_promotion[:total_tickets].to_i
      tickets_remaining = event.tickets_remaining.to_i - payable_promotion[:total_tickets].to_i
      in_progress = event.inprogress.to_i + payable_promotion[:total_tickets].to_i
      event.update_attributes(:tickets_remaining => tickets_remaining, :inprogress => in_progress)
    end
  end

  def self.success_process(event, payable_promotion)
    event = Event.find(event.id)
    in_progress = event.inprogress.to_i - payable_promotion[:total_tickets].to_i
    event.update_attributes(:inprogress => in_progress)
  end


  def self.failure_process(event, payable_promotion)
    event = Event.find(event.id)
    tickets_remaining = event.tickets_remaining.to_i + payable_promotion[:total_tickets].to_i
    in_progress = event.inprogress.to_i - payable_promotion[:total_tickets].to_i
    event.update_attributes(:tickets_remaining => tickets_remaining, :inprogress => in_progress)
  end

  #def compare_with_start_date
  #self.errors = "'sale end' date should be before 'event start' date" unless self.start_date >= self.sale_ends_at
  #end


  def custom_update(event_params)
    self.tickets_remaining = event_params[:tickets_remaining]
    if self.tickets_remaining_changed?
      self.tickets = self.calculate_newly_added_tickets
    end
    update_attributes(event_params)
  end

  def calculate_newly_added_tickets
    old_tickets = self.tickets
    array_of_tickets = self.tickets_remaining_change
    return old_tickets if array_of_tickets.nil?
    if (array_of_tickets[1] >=  0) && (array_of_tickets[0] > array_of_tickets[1])
      tickets_change = array_of_tickets[0] - array_of_tickets[1]
      return old_tickets - tickets_change
    elsif (array_of_tickets[1] >=  0) && (array_of_tickets[0] <  array_of_tickets[1])
      tickets_change = array_of_tickets[1] - array_of_tickets[0]
      return old_tickets + tickets_change
    else
      return old_tickets
    end
  end

end
  

