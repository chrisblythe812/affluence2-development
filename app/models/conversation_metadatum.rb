class ConversationMetadatum < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation

  before_update :update_unread_messages_counter

  private

  def update_unread_messages_counter
    if changed_attributes.keys.include?("read") || changed_attributes.keys.include?("archived")
      if was_marked_as_unread? || archived_was
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

