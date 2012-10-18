class ConversationMetadatum < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation
  validates :conversation_id, :uniqueness => {:scope => :user_id}

  before_update :update_unread_messages_counter

  private

  def update_unread_messages_counter
    self.read = true if self.archived && !self.read

    if changed_attributes.keys.include?("read")
      if was_marked_as_unread?  
        user.increment(:unread_messages_counter).save
      else
        user.decrement(:unread_messages_counter).save
      end
    end
  end

  def was_marked_as_unread?
    read_was
  end
end

