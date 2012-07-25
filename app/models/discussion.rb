class Discussion < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy


  validates :question, :presence => true
  validates :user_id, :presence => true


  def self.build_search_query(query_text)
    array_elements =  query_text.split(" ")
    array_elements.join(" | ")
  end


  #scope :search, lambda { |query| {
      #:conditions => ["(to_tsvector('english',discussions.question) @@ to_tsquery(?)) or (to_tsvector('english',comments.body) @@ to_tsquery(?))", query, query],
      #:select => "discussions.id as id, discussions.user_id as user_id, discussions.question as question, discussions.created_at as created_at, discussions.updated_at as updated_at, discussions.last_comment_at as last_comment_at, ts_rank_cd(to_tsvector('english',discussions.question), to_tsquery('english','#{query}' )) + ts_rank_cd(to_tsvector('english',comments.body), to_tsquery('english','#{query}' )) as rank",
      #:order => "rank DESC, last_comment_at DESC",
      #:joins => "LEFT  JOIN comments ON comments.commentable_id = discussions.id AND comments.commentable_type='Discussion'"
  #} }


  #scope :search, lambda { |query| {
     # :conditions => ["(to_tsvector('english',discussions.question) @@ to_tsquery(?)) or (to_tsvector('english',comments.body) @@ to_tsquery(?))", query, query],
     # :select => "
      #            DISTINCT discussions.*,
     #             (case
      #            when
      #              ts_rank_cd(to_tsvector('english',comments.body), to_tsquery('english','#{query}' )) is NULL
       #           then
       #             ts_rank_cd(to_tsvector('english',discussions.question), to_tsquery('english','#{query}' ))
       #           else
       #             (
       #             ts_rank_cd(to_tsvector('english',comments.body), to_tsquery('english','#{query}' )) +
       #             ts_rank_cd(to_tsvector('english',discussions.question), to_tsquery('english','#{query}' ))
       #             )
       #          end
       #             )
        #           as rank " ,
     # :joins => "LEFT  JOIN comments ON comments.commentable_id = discussions.id AND comments.commentable_type='Discussion'",
     # :order => "rank DESC, last_comment_at DESC",
    #}
 # }

   scope :search, lambda{ |query|

   find_by_sql("
   select distinct x.id, x.user_id as user_id, x.question as question, x.created_at as created_at,
 x.updated_at as updated_at, x.last_comment_at as last_comment_at, sum(x.r3)/count(x.r3) as r4 from (

   SELECT DISTINCT discussions.*,
(case
when
	ts_rank_cd(to_tsvector('english',comments.body), to_tsquery('english','#{query}' )) is NULL
then
	ts_rank_cd(to_tsvector('english',discussions.question), to_tsquery('english','#{query}' ))
else
	(
	ts_rank_cd(to_tsvector('english',comments.body), to_tsquery('english','#{query}' )) +
	ts_rank_cd(to_tsvector('english',discussions.question), to_tsquery('english','#{query}' ))
	)
end
	)
 as r3
 FROM "+'discussions'+"
 LEFT JOIN comments ON comments.commentable_id = discussions.id AND comments.commentable_type='Discussion'
 WHERE
 (
 (to_tsvector('english',discussions.question) @@ to_tsquery('#{query}')) or
 (to_tsvector('english',comments.body) @@ to_tsquery('#{query}'))
 )
 ORDER BY r3 DESC, last_comment_at DESC ) as x

 group by x.id,x.user_id,x.question,x.created_at, x.updated_at, x.last_comment_at
 order by r4 desc
   ")

  }

  end
