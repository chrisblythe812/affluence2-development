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
    :password => "vegpuf",
    :database => "affluence_staging_25_june"
  )
end

def connect_to_new_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "vegpuf",
    :database => "affluence2_22_june"
  )
end

def create_new_coversation_obj(conversation_obj)
  connect_to_new_db
  _conv = Conversation.new
  _conv.save!
  return _conv.id
end

def create_message(body,subject,sender_id,recipient_id,conversation_id,created_at,updated_at)
  connect_to_new_db
  _conv = Conversation.new
  _conv_msg =
    _msg = Message.new(:body => body, :subject => subject, :conversation_id => conversation_id,
    :sender_id => sender_id, :recipient_id => recipient_id, :created_at => created_at, :updated_at => updated_at)
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
  task :message_dumper_delta_start , :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"
    puts "Rake Started.."
    connect_to_new_db


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

    #ActiveRecord::Base.logger = Logger.new(STDERR)
     
    connect_to_old_db
    #old_conversations = ProdConversation.where(:id => 29984)
    old_conversations = ProdConversation.find(:all,:conditions => "created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'",:order => 'ID ASC')


    old_conversations.each do |old_conversation|

      connect_to_old_db

      MSG_LOG.info "--------------------------------------------------------"
      MSG_LOG.info "old_conversation : #{old_conversation.inspect}"
      MSG_LOG.info "old_conversation.messages : #{old_conversation.messages}"
  
      messages =  old_conversation.messages
      unless messages.blank?
        connect_to_new_db

        # TODO : Search in new system where sender_id, recipient_id exists in COV MD

        # if exist use that as new conversation else create a new one.


        new_conversation = Conversation.new
        messages.each do |message|
          
          MSG_LOG.info "message : #{message.inspect}"
          unless message.body.nil? or message.body.blank? then
            next if (get_new_sender(message.sender_id).nil? || get_new_sender(message.recipient_id).nil?)
            MSG_LOG.info "Sender : #{get_new_sender(message.sender_id).id}"
            MSG_LOG.info "Recipient : #{get_new_sender(message.recipient_id).id}"
            new_conversation.messages.build({
                body: message.body,
                subject: message.subject,
                sender_id: get_new_sender(message.sender_id).id,
                recipient_id: get_new_sender(message.recipient_id).id,
                created_at: message.created_at,
                updated_at: message.updated_at
              })

            new_conversation.save!
            p "Conversation #{new_conversation.id} saved."
            MSG_LOG.info "Conversation #{new_conversation.id} saved."
            MSG_LOG.info "Errors : #{new_conversation.errors.inspect}"
          else
            p "Message body is not present."
            MSG_LOG.info "Message body is not present."

          end

        end
      else
        p "Coversation has no messages."
        MSG_LOG.info "Coversation has no messages."
      end
    end
  end
end





