class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_many :schedules, :dependent => :destroy
  has_many :includes, :dependent => :destroy
end
 