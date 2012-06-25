class Schedule < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :title, :date

  after_save :update_event_start_date

  def update_event_start_date
    start_date = event.schedules.first.date
    event.update_attributes(:start_date =>  start_date)
  end
end
