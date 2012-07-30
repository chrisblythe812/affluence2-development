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

def connect_to_old_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "vegpuf",
    :database => "affluence_staging_23july"
  )
end


namespace :affluence do
  desc "This will dump Affluenece conversations  to  data into Affluence2."
  task :merge_duplicate_conversations_delta, :start, :end, :needs => :environment do |t, args|

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

    @msg = ProdMessage.find(:all, :conditions => "created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'", :order => "ID Asc")
    @msg.each do | _msg |

      _new_msg =  Message.find_by_body(_msg.body)

        p "-------------------------------------------------------"
        p "#{_msg.id} : #{_msg.body} : #{_new_msg.id}"
        p "------------------------------------------------------"
      
      connect_to_old_db

    end

  end
end
