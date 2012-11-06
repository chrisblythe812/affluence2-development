class Conversation < ActiveRecord::Base
  paginates_per 5
  has_many :messages, :order => "created_at"
  has_many :conversation_metadata, :dependent => :destroy
  has_many :interactions, :dependent => :destroy
  
  scope :for_user, lambda { |user|
    joins(:conversation_metadata).
        includes(:messages).
        where("conversation_metadata.user_id = ?", user.id).
        order("messages.updated_at DESC")
  }

  # at least one message in the conversation was sent to user
  scope :for_recipient, lambda { |user|
    joins(:conversation_metadata).
        includes(:messages).
        where("conversation_metadata.user_id = ? AND messages.recipient_id = ?", user.id, user.id)
  }

  scope :archived?, lambda { |is_archived|
    joins(:conversation_metadata).
        where("conversation_metadata.archived = ?", is_archived)
  }

  scope :read?, lambda { |is_read|
    joins(:conversation_metadata).
        where("conversation_metadata.read = ?", is_read)
  }


  accepts_nested_attributes_for :messages
  # attr_accessible :messages_attributes

  # the user <user> is having a conversation with.

   #Usage call with the current-user and the text as the query to be searched
   def self.matching_conversation(user_id,query)
     find_by_sql(["
     with selected_user_ids as
        (
          select distinct user_id
          from profiles
          where (user_id is not null)
                and ( to_tsvector('english', COALESCE(first_name,'') || ' ' || COALESCE(last_name,'')) @@ plainto_tsquery('english', ?))
        )
        select id from (
          select conversation_id as id  ,rank() over (partition by conversation_id order by created_at desc) as internal_rank
          from messages
          where  ((sender_id=? and recipient_id in (select * from selected_user_ids) ) or  (recipient_id=? and sender_id in (select * from selected_user_ids) ))
        ) matching_users
        where internal_rank=1

        union

        select id from (
          select distinct messages.conversation_id as id  ,rank() over (partition by conversation_id order by created_at desc) as internal_rank
          from messages
          where to_tsvector('english', COALESCE(subject,'') || ' ' || COALESCE(body,''))  @@ plainto_tsquery('english', ?)
                and  (sender_id=? or recipient_id=?)
        ) matching_subs_body
        where internal_rank = 1
        limit 100
     ",query,user_id,user_id,query,user_id,user_id])
   end
  

  def recipient_for(user)
    results = messages.where(:sender_id => user.id)
    if !results.empty?
      results.first.recipient
    else
      messages.first.sender
    end
  end

  def archive!(user)
    conversation_metadata.where(:user_id => user.id).each do |meta|
      meta.update_attribute(:archived, true)
    end
  end

  def unarchive!(user)
    conversation_metadata.where(:user_id => user.id).each do |meta|
      meta.update_attribute(:archived, false)
    end
  end

  def mark_as_read!(user)
    conversation_metadata.where(:user_id => user.id).each do |meta|
      meta.update_attribute(:read, true)
    end
  end

  def archived?(user)
    result = conversation_metadata.where(:user_id => user.id, :archived => true)
    !result.empty?
  end

  def read?(user)
    result = conversation_metadata.where(:user_id => user.id, :read => true)
    !result.empty?
  end

  def self.get_conversation_for(*args)
    temp = "select distinct conversation_id as id from conversation_metadata
             where user_id = "
    query = ""
    args.each do |id|
      query = query + temp + id.to_s
      unless (args.last == id)
        query = query + " intersect "
      end
    end

    result = find_by_sql(query)
    if result.size > 1
      unless result.blank?
        conversation_ids = []

        result.each do |conv|
          conversation_ids << conv.id
        end

        query = "select conversation_id as id from conversation_metadata
 where conversation_id in (#{conversation_ids.join(',')})
 group by conversation_id
 having count(user_id)=#{result.size}"
        result = find_by_sql(query)
      end
    end
    result
  end
end

