class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy


  validates :question, :presence => true
  validates :user_id, :presence => true


  def self.build_search_query(query_text)
    array_elements =  query_text.split(" ")
    array_elements.join(" | ")
  end


  scope :search, lambda { |query| {
      :conditions => ["(to_tsvector('english',discussions.question) @@ to_tsquery(?)) or (to_tsvector('english',comments.body) @@ to_tsquery(?))", query, query],
      :select => "*, ts_rank_cd(to_tsvector('english',discussions.question), to_tsquery('english','#{query}' )) + ts_rank_cd(to_tsvector('english',comments.body), to_tsquery('english','#{query}' )) as rank",
      :order => "rank DESC, last_comment_at DESC",
      :joins => :comments
  } }

end
