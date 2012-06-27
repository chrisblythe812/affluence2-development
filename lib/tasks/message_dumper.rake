require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'


def connect_to_old_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "postgres",
    :database => "affluence_test"
  )
  p '  Connected to affluence_production--------------------------------------------'
end

def connect_to_new_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "postgres",
    :database => "affluence2_test"
  )
  p '  Connected to affluence2_test--------------------------------------------'
end

def create_new_coversation_obj(conversation_obj)
  connect_to_new_db
  _conv = Conversation.new
  _conv.save!
  return _conv.id
end

def create_message(body,subject,sender_id,recipient_id,conversation_id)
  connect_to_new_db
  _conv = Conversation.new
  _conv_msg =
    _msg = Message.new(:body => body, :subject => subject, :conversation_id => conversation_id,
    :sender_id => sender_id, :recipient_id => recipient_id)
  _msg.save!
  return _msg.id
end

def get_latest_user(email)
  connect_to_new_db
  _user = User.find_by_email(email)
  return _user
end



namespace :affluence do
  desc "This will dump Affluenece conversations  to  data into Affluence2."
  task :message_dumper_start => :environment do
    puts "Rake Started.."
    connect_to_new_db
    Conversation.all.each { |x| x.delete}
    ConversationMetadatum.all.each { |x| x.delete}
    Connection.all.each {|x| x.delete}
    ConnectionRequest.all.each {|x| x.delete}
    Message.all.each {|x| x.delete}
    puts "  Deleted previous records.."


    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy      
      connect_to_old_db
    end

    class ProdConversation < ActiveRecord::Base
      set_table_name :conversations
      has_many :messages, :foreign_key => 'conversation_id', :order => "created_at"
      has_many :conversation_metadata, :foreign_key => 'conversation_id', :dependent => :destroy
      connect_to_old_db
    end
    class ProdConversationMetadatum < ActiveRecord::Base
      set_table_name :conversation_metadata
      belongs_to :user
      belongs_to :conversation
    end

    class ProdFriendRequest < ActiveRecord::Base
      set_table_name :friend_requests
      belongs_to :requestor, :class_name => "User"
      belongs_to :requestee, :class_name => "User"
      connect_to_old_db
    end

    class ProdFriendship < ActiveRecord::Base
      set_table_name :friendships
      belongs_to :user, :touch => true                            #this is used for friends cache
      belongs_to :friend, :class_name => 'User', :touch => true   #this is used for friends cache
      connect_to_old_db
    end

    class ProdMessage < ActiveRecord::Base
      set_table_name :messages
      belongs_to :sender, :class_name => "ProdUser"
      belongs_to :recipient, :class_name => "ProdUser"
      belongs_to :conversation
      connect_to_old_db
    end

    def get_new_sender(old_sender_id)
      connect_to_old_db
      old_email = ProdUser.find(old_sender_id).email
      old_email.downcase!

      connect_to_new_db
      new_sender = User.find_by_email(old_email)
      return new_sender
    end

    ActiveRecord::Base.logger = Logger.new(STDERR)
     
    connect_to_old_db
#    old_conversations = ProdConversation.where(:id => 16076)
    old_conversations = ProdConversation.all
    p "old_conversations = #{old_conversations}"

    old_conversations.each do |old_conversation|
      connect_to_old_db
      p "old_conversation = #{old_conversation}"
      p "old_conversation.messages = #{old_conversation.messages}"
  
      messages =  old_conversation.messages
      unless messages.blank?
        connect_to_new_db
        new_conversation = Conversation.new
        messages.each do |message|
          p ''
          p ''
          p ''
          p '-------------------------------------message loop--------------------------------------------'
          p "message = #{message.inspect}"
          next if (get_new_sender(message.sender_id).nil? || get_new_sender(message.recipient_id).nil?)
          p '----Continue-----------'
          new_conversation.messages.build({
              body: message.body,
              subject: message.subject,
              sender_id: get_new_sender(message.sender_id).id,
              recipient_id: get_new_sender(message.recipient_id).id
            })
          p "----------new_conversation.save!   ----------------"

          new_conversation.save!
          p new_conversation.errors
          p "----------save!   ----------------"
        end
      else
        p '--------------conversation has blank messages------------------'
      end
    end
 
    #    new_conversation_id = create_new_coversation_obj(conversation_obj)
    #
    #    connect_to_old_db
    #    conversation_obj.messages.each do | message_obj |
    #      p message_obj.inspect
    #      p "Sender: "+ProdUser.find(message_obj.sender_id).email
    #      p "Recipient: "+ProdUser.find(message_obj.recipient_id).email
    #
    #      new_sender_obj = get_latest_user(ProdUser.find(message_obj.sender_id).email)
    #      p new_sender_obj
    #
    #      connect_to_old_db
    #      new_recipient_obj = get_latest_user(ProdUser.find(message_obj.recipient_id).email)
    #      p new_recipient_obj
    #      new_message_id = create_message(message_obj.body,message_obj.subject,new_sender_obj.id,new_recipient_obj.id,new_conversation_id)
    #      p new_message_id
    #      connect_to_old_db
    #    end
    

  end
end





