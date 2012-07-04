class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy


  validates :question, :presence => true
  validates :user_id, :presence => true
  scope :search, lambda { |query|
    find_by_sql ["SELECT *
      FROM discussions   
      WHERE to_tsvector('english', question )
      @@ plainto_tsquery('english', ?)

      order by discussions.last_comment_at", query]
  }
end
