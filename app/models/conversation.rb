class Conversation < ActiveRecord::Base
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

end

