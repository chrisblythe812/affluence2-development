class PhotoStream < ActiveRecord::Base
  belongs_to :profile
  has_many :photos, :as => :photoable, :dependent => :destroy

  
  before_save :check_title

  def check_title
    self.title = 'Untitled Album' if (self.title.nil? || self.title.strip.empty?)
  end
end
