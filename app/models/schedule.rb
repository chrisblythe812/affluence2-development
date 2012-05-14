class Schedule < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :title, :date
end
