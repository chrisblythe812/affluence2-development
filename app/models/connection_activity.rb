class ConnectionActivity < Activity
  has_many :activities, :as => :resource, :dependent => :destroy
end
