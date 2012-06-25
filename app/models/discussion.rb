class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy

  
  validates :question, :presence => true
  validates :user_id, :presence => true

end
