class PhotoStream < ActiveRecord::Base
  belongs_to :profile
  has_many :photos, :as => :photoable, :dependent => :destroy



  before_save :check_title

  def check_title
    self.title = 'Untitled Albumn' if self.title.strip!.size < 1
  end
end
