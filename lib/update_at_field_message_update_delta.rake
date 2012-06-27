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
  task :updated_at_field_message_update_delta, :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"
    puts "Rake Started.."
   

   
    class ProdMessage < ActiveRecord::Base
      set_table_name :messages
      belongs_to :sender, :class_name => "ProdUser"
      belongs_to :recipient, :class_name => "ProdUser"
      belongs_to :conversation
      connect_to_old_db
    end

    @msg = ProdMessage.find(:all,:conditions => "created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'",:order => "ID Asc")
    @msg.each do | _msg |
      p _msg.id+61
      connect_to_new_db

      Message.find(_msg.id+61).update_attributes(:updated_at => _msg.updated_at)
      p "Updating Message #{_msg.id+61} with #{_msg.updated_at}"
      connect_to_old_db
      
    end
   
  end
end





