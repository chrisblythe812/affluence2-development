require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'


def connect_to_new_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "vegpuf",
    :database => "affluence_19july"
  )
end


def build_array_of_all_numbers(_msg)
  # Build Respective Array
  _arr = Array.new
  _msg.each do | _each_message |
    _sub_array = Array.new
    _sub_array << _each_message.sender_id
    _sub_array << _each_message.recipient_id
    _sub_array << _each_message.conversation_id
    _arr << _sub_array
  end
p "Array initial : #{_arr.inspect}"
  # Build hash and Merge [4:23] and [23:4] if 4 and 23 have conversations
  _hash = Hash.new { |hash, key| hash[key] = [] }
  _arr.each do | _sub_array |
    if _hash.has_key?(_sub_array[1].to_s+":"+_sub_array[0].to_s)  then
      _hash[_sub_array[1].to_s+":"+_sub_array[0].to_s] << _sub_array[2]
    else
      _hash[_sub_array[0].to_s+":"+_sub_array[1].to_s] << _sub_array[2]
    end
  end
p "Hash after merge : #{_hash.inspect}"
  # Sort Conversations in Final Hash
  _hash.each do |k,v|
    _hash[k] = _hash[k].sort
  end
p "Hash after sort : #{_hash.inspect}"
  _hash
end



namespace :affluence do
  desc "This will dump Affluenece conversations  to  data into Affluence2."
  task :merge_duplicate_conversations => :environment do
    puts "Rake Started.."
    connect_to_new_db

    ActiveRecord::Base.logger = Logger.new(STDERR)


    _msg = Message.find_by_sql("select  sender_id,recipient_id,conversation_id from messages group by sender_id,recipient_id,conversation_id order by sender_id,recipient_id,conversation_id");


    _hash = build_array_of_all_numbers(_msg)

    # Build Keys by pushing 4:4 king of similar keys to last in the array.

    similar_keys_arr = Array.new
    original_arr = _hash.keys
    _hash.keys.each do | _key |
      if _key.split(":")[0] == _key.split(":")[1]
        similar_keys_arr << _key
      end
    end
p "Original Array : #{original_arr.inspect}"
p "Similar Key Array : #{similar_keys_arr.inspect}"
    interm_arr = original_arr - similar_keys_arr
    final_arr = interm_arr + similar_keys_arr
p "Interm Array : #{interm_arr.inspect}"
p "Final Array : #{final_arr.inspect}"
    processed_arr = Array.new

    interm_arr.each do | key |
p "-----------------------------------------------------"
p "_hash[key] before : #{_hash[key].inspect}"
p "-----------------------------------------------------"
      _hash[key].each do | key |
        if processed_arr.include?(key) then
          _hash[key].delete(key)
        end
      end
p "-----------------------------------------------------"
p "_hash[key] after : #{_hash[key].inspect}"
p "-----------------------------------------------------"
      new_conversation_array = _hash[key].uniq.sort unless _hash[key].nil?
p "new_conversation_array Array : #{new_conversation_array.inspect}"
      _conv = Conversation.find_by_id(new_conversation_array[0])
p "-----------------------------------------------------"
p "conversation id to be Updated : #{_conv.id}"
p "-----------------------------------------------------"

      processed_arr = processed_arr + _hash[key]
p "Processed Array : #{processed_arr.inspect}"
      var = new_conversation_array.join(",")
      _msg = Message.find(:all,:conditions => "conversation_id in (#{var})")
p "Messages after Query : #{_msg.inspect}"
      _msg.each do | _each_msg |
        _updated_at = _each_msg.updated_at
        _each_msg.update_attributes(:created_at => _conv.created_at,:updated_at => _updated_at,:conversation_id => _conv.id)
        DUP_MSG_LOG.info "#{_each_msg.id} : #{_each_msg.sender_id} : #{_each_msg.recipient_id} has been updated with #{_conv.id}"
        p "#{_each_msg.id} : #{_each_msg.sender_id} : #{_each_msg.recipient_id} has been updated with #{_conv.id}"
      end


      DUP_MSG_LOG.info "-----------------------------------------------------"
      p "-----------------------------------------------------"
    end

  end
end
