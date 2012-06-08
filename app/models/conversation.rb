class Conversation < ActiveRecord::Base
  paginates_per 5
  has_many :messages, :order => "created_at"
  has_many :conversation_metadata, :dependent => :destroy

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
  













    
#    unless Connection.are_connected?(self.sender,  self.recipient)
#      #       ConnectionRequest.find_or_create_by_requestor_id_and_requestee_id(current_user.id, recipient_user.id)
#      if ConnectionRequest.where(:requestor_id => self.sender, :requestee_id => self.recipient).first
#        if ConnectionRequest.where(:requestor_id => self.recipient, :requestee_id => self.sender).first
#          Connection.make_connection(self.sender,  self.recipient)
#        end
#      else
#        ConnectionRequest.create!(:requestor_id => self.recipient, :requestee_id => self.sender)
#      end
#
##
##      logger.info 'not yet connected  -----------------------------------------------------   '
##             if   ConnectionRequest.present?(self.sender, self.recipient)
##      messages = self.messages
##
##      if messages.size > 1
##        messages = messages.last(2)
##        logger.info messages.inspect
##        unless messages[0].sender_id == messages[1].sender_id
##          Connection.make_connection(self.sender,  self.recipient)
##          logger.info ' connected  -----------------------------------------------------   '
##        end
##      end
#
#    end
#    #    logger.info ' make_connection_req55555555555555555555555555555555555555555555555555555 '
#    #    logger.info new_saved_message.inspect
#    #    connected =  Connection.are_connected?
#    #    logger.info   connected
#    #
#    #    con_req = ConnectionRequest.where(:requestor_id => new_saved_message.sender_id, :requestee_id => new_saved_message.recipient_id)
#    #
  

 
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

