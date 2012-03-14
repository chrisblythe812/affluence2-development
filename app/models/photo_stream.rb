class PhotoStream < ActiveRecord::Base
  belongs_to :profile
  has_many :photos, :as => :photoable, :dependent => :destroy
end
