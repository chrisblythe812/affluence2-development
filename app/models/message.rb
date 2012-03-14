class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  belongs_to :conversation

  after_create :create_or_update_conversation_metadata
  attr_accessor :recipient_name
  private

  def create_or_update_conversation_metadata
    meta = conversation.conversation_metadata
    if meta.empty?
      meta.create(:user => sender, :archived => false, :read => true)
      meta.create(:user => recipient, :archived => false, :read => false)
      recipient.increment(:unread_messages_counter).save
    else
      meta.each do |m|
        m.archived = false
        m.read = false if m.user == recipient
        m.save
      end
    end
  end
end
