class Event < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy

end
 