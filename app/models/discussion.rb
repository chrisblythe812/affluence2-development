class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy


  validates :question, :presence => true
  validates :user_id, :presence => true
  #scope :search, lambda { |query|
    #find_by_sql ["SELECT *
     # FROM discussions
      #WHERE to_tsvector('english', question )
      #@@ plainto_tsquery('english', ?)

      #order by discussions.last_comment_at", query]
  #}


  scope :search, lambda { |query|
    find_by_sql (" SELECT *, ts_rank_cd(to_tsvector('english',question), to_tsquery('english',' #{query}' )) as rank
  FROM discussions WHERE to_tsvector('english',question) @@ to_tsquery('#{query}') ORDER BY rank DESC, last_comment_at DESC")
  }
end
