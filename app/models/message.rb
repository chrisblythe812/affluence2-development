class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  belongs_to :conversation, :touch => true

  after_create :create_or_update_conversation_metadata, :notify_message_through_email
  attr_accessor :recipient_name

  validates_presence_of :body, :sender_id, :recipient_id

  after_save :make_connection_req


  def make_connection_req
    _conn = Connection.where(:user_id => self.sender_id, :friend_id => self.recipient_id)
    if _conn.blank?
      _conn_req = ConnectionRequest.where(:requestor_id => self.sender_id, :requestee_id => self.recipient_id)
      if _conn_req.blank?
        check_record = check_reverse_exists_or_not(self.sender_id, self.recipient_id)
        if !check_record.blank?
          check_and_clear_connection_request(self.recipient_id, self.sender_id, check_record)
        else
          # create connection request
          conec_req = ConnectionRequest.create(:requestor_id => self.sender_id, :requestee_id => self.recipient_id)
        end
      else
      end
    else
      # connection exists. dont create any connection
    end
  end


  def check_reverse_exists_or_not(from, to)
    _conn_req = ConnectionRequest.find(:first, :conditions => [' "requestor_id" = ? and  "requestee_id" = ?', self.recipient_id.to_i, self.sender_id.to_i])
    return _conn_req
  end

  def check_and_clear_connection_request(from, to, connection_request_object)
    # create connection and delete coneection request
    c1 = Connection.create(:user_id => from, :friend_id => to)
    c1.notify_user_through_email
    c2 = Connection.create(:user_id => to, :friend_id => from)
    c2.notify_user_through_email
    puts "created c1-#{c1.id}--c2--#{c2.id}"
    # delete connection request
    puts "#{connection_request_object.id}"
    connection_request_object.destroy
  end


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

  def notify_message_through_email
    NotificationTracker.create(:user_id => self.sender_id, :channel => 'email', :subject => "message",
                               :status => 'pending', :notifiable_id => self.id, :notifiable_type => 'Message',
                               :notifiable_mode => 1, :scheduled_date => Date.today)
  end
end
