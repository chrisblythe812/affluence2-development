require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'

#TODO : Timestamps needs to be replaced.
#
## account_status
# available ( see_me )
# Special Offers
# 
# Credentials
# Facebook
# Disclousure Signed
# 
#Paramalink fix for polish chars : needs to be tested.

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
  desc "This will dump Affluenece production data into Affluence2."
  task :user_profile_delta_dumper, :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"
    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy
      connect_to_old_db
    end

    class ProdProfile < ActiveRecord::Base
      set_table_name :profiles
      belongs_to :user
      has_many :positions
      acts_as_taggable_on :interests, :expertises
      connect_to_old_db
    end

    class ProdPosition < ActiveRecord::Base
      set_table_name :positions
      belongs_to :profile
      connect_to_old_db
    end

    class ProdOrganization < ActiveRecord::Base
      set_table_name :organizations
      belongs_to :profile
      connect_to_old_db
    end

    class Club < ProdOrganization
      connect_to_old_db
    end

    class Charity < ProdOrganization
      connect_to_old_db
    end


    # ActiveRecord::Base.logger = Logger.new(STDERR)

    ProdUser.find(:all,:conditions => "created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'", :order => 'ID ASC').each do | user_obj |
      connect_to_old_db
      p "-------------#{user_obj.email}------------------------------------"
      USER_PROFILE_LOG.info "-------------#{user_obj.email}------------------------------------"
    end

  end
end


    

