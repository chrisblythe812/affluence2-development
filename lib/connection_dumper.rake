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
    :database => "affluence_staging"
  )
end

def connect_to_new_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "vegpuf",
    :database => "affluence2_migration_13_jun_mid_night"
  )
end

def get_new_user_id(email)
  connect_to_new_db
  _user = User.find_by_email(email.downcase)
  return _user
end

def save_connection(new_user_id,new_friend_id)
  connect_to_new_db
  _connection = Connection.new(:user_id => new_user_id,:friend_id => new_friend_id)
  _connection.save!
  return _connection.id
end


namespace :affluence do
  desc "This will dump Affluenece production data into Affluence2."
  task :connection_dumper_start, :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"

    ENV['MIGRATION'] = 'true'

    puts "Rake Started.."
    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy
      connect_to_old_db
    end

    class ProdFriendship < ActiveRecord::Base
      set_table_name :friendships
      belongs_to :user, :touch => true                            #this is used for friends cache
      belongs_to :friend, :class_name => 'User', :touch => true   #this is used for friends cache
      connect_to_old_db
    end

    #ActiveRecord::Base.logger = Logger.new(STDERR)
    connect_to_old_db
    ProdFriendship.find(:all,:conditions => "ID > #{args[:start]} and ID <= #{args[:end]}", :order => 'ID ASC').each do | friend_obj |
      new_user = get_new_user_id(ProdUser.find(friend_obj.user_id).email)
      connect_to_old_db
      new_friend = get_new_user_id(ProdUser.find(friend_obj.friend_id).email)
      unless new_user.nil? or new_friend.nil? then

        _existing_conn = Connection.where(:user_id => new_user.id, :friend_id => new_friend.id).first

        if _existing_conn.nil? or _existing_conn.blank? then
          _conn_id = save_connection(new_user.id,new_friend.id)
          p "connection #{_conn_id} has been created."
          CON_LOG.info "connection #{_conn_id} has been created."
        else
          p "connection #{_existing_conn.id} alredy existing."
          CON_LOG.info "connection #{_existing_conn.id} alredy existing."
        end
      else
        connect_to_old_db
        p "User : #{ProdUser.find(friend_obj.user_id).email} is not present in the new DB."
        CON_LOG.info "User : #{ProdUser.find(friend_obj.user_id).email} is not present in the new DB."
      end

      p ENV['MIGRATION']
      connect_to_old_db

    end
  end
end





