class Include < ActiveRecord::Base
  belongs_to :event

  validates_presence_of :title

end
