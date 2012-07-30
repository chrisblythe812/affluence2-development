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
    :database => "affluence2_migration_7_jun"
  )
end

namespace :affluence do
  desc "This will dump Affluenece production data into Affluence2."
  task :user_profile_verifier => :environment do
    puts "Rake Started.."

  user_count = 18833;

    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy
      connect_to_old_db
    end

    #ActiveRecord::Base.logger = Logger.new(STDERR)

    ProdUser.find(:all,:conditions => "id >= 18834").each do | u |
      user_count = user_count+1
      _email = u.email
      _status = u.status
      connect_to_new_db
      _user = User.find_by_email(_email.downcase)

      if _user.nil? or _user.blank? then
        USER_PROFILE_PROGRESS_LOG.info "#{user_count}. #{_email} Does Not exist & User Status is : #{_status}"
        p "#{user_count}. #{_email} Does Not exist & User Status is : #{_status}"
      else
        USER_PROFILE_PROGRESS_LOG.info "#{user_count} - #{_email}"
        p "#{user_count}. #{_email} - Success"
      end
      connect_to_old_db
    end

  end
end




