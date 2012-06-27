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


namespace :affluence do
  desc "This will dump Affluenece conversations  to  data into Affluence2."
  task :remove_duplicate_conversations_delta, :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"
    puts "Rake Started.."
    connect_to_new_db

    #    ActiveRecord::Base.logger = Logger.new(STDERR)
    
    _msg = Message.find_by_sql("select distinct sender_id,recipient_id from messages where created_at > '#{args[:start]}' and created_at <= '#{args[:end]}' order by sender_id,recipient_id")
    _msg.each do | _msg_instance |
            
      _total_conversation = Message.find(:all,
        :conditions => "sender_id = #{_msg_instance.sender_id} and recipient_id = #{_msg_instance.recipient_id} and created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'",
        :order => "conversation_id")

      count = 0
      _new_conversation_id = _total_conversation[0].conversation_id
      _total_conversation.each do | _each_msg |
        if count >= 1 then
        
          unless _each_msg.conversation.nil?
            p "Updating message : #{_each_msg.id} with Conversation id:#{_new_conversation_id}"
            UPDATE_MSG_LOG.info "Updating message : #{_each_msg.id} with Conversation id:#{_new_conversation_id}"
            _each_msg.update_attributes(:conversation_id => _new_conversation_id)
          end
        end
        count = count+1
      
        p "----------------------------------------------------"
        UPDATE_MSG_LOG.info "----------------------------------------------------"
      end
    end
  end
  
end





