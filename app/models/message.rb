class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  belongs_to :conversation

  after_create :create_or_update_conversation_metadata, :notify
  attr_accessor :recipient_name

  validates_presence_of :body, :sender_id, :recipient_id


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

  def notify
    NotificationTracker.create(:user_id => self.recipient_id, :channel => 'email', :subject => "Connection",
        :status => 'pending', :notifiable_id => self.conversation.id, :notifiable_type => 'Conversation',
        :notifiable_mode => 1, :scheduled_date => Date.today)
  end
end
