require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'

#TODO : Timestamps needs to be replaced.
#Paramalink fix for polish chars : needs to be tested.


def status_check(status)
	if status == 'approved'
		return 'active'
	else
		return 'suspended'
	end
end


def create_user_obj(email,status,encrypted_password,first_name,last_name,
    city,state,postal_code,country,phone,gender,birthday,
    income,net_worth,education,bio,marital_status,
    suite,middle_name,full_name,created_at,updated_at,title,company,
    expertise_list,interest_list,assosiation_list
  )
 

  connect_to_new_db
  _u = User.new(:email => email,:status => status, :password => encrypted_password, :plan => 'free', :created_at => created_at, :updated_at => updated_at)
  _u.build_profile(:first_name => first_name, :last_name => last_name,
    :city => city, :state => state, :country => country,
    :phone => phone, :bio => bio, :middle_name => middle_name,
    :full_name => full_name, :title => title, :company => company )
  _u.profile.expertise_list = expertise_list
  _u.profile.interest_list = interest_list
  _u.profile.association_list = assosiation_list

  _u.save!
  p "#{_u.id}.#{_u.email} : #{_u.status}"
  return _u
  # _u.update_attribute('encrypted_password', encrypted_password)
end

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


    puts "Rake Started.."

    active_user_count = 0;



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
      if (user_obj.status != 'invited')

        unless user_obj.encrypted_password.nil? or user_obj.encrypted_password.blank?

          if user_obj.profile.first_name.nil? or user_obj.profile.first_name.blank?
            user_obj.profile.first_name = user_obj.email.split("@")[0]
          end

          if user_obj.profile.last_name.nil? or user_obj.profile.last_name.blank?
            user_obj.profile.last_name = user_obj.email.split("@")[0]
          end

          if user_obj.profile.city.nil? or user_obj.profile.city.blank?
            user_obj.profile.city = "."
          end

          if user_obj.profile.country.nil? or user_obj.profile.country.blank?
            user_obj.profile.country = "."
          end

          unless ProdPosition.find_all_by_profile_id(user_obj.profile.id).last.nil? then
            title = ProdPosition.find_all_by_profile_id(user_obj.profile.id).last.title
            company = ProdPosition.find_all_by_profile_id(user_obj.profile.id).last.company
          else
            title = ""
            company = ""
          end

          _interest_list = user_obj.profile.interest_list

          _expertise_list = user_obj.profile.expertise_list

          str_name = ""
          (ProdOrganization.find_all_by_profile_id(user_obj.profile.id)).each do | obj |
            str_name = str_name + obj.name + ','
          end

          USER_PROFILE_LOG.info "#{user_obj.email}"
          USER_PROFILE_LOG.info "Assosiations list : #{str_name.chop}"
          USER_PROFILE_LOG.info "Expertise list : #{_expertise_list}"
          USER_PROFILE_LOG.info "INterest list : #{_interest_list}"

          connect_to_new_db
          _existing_user_obj = User.find_by_email(user_obj.email)
          if _existing_user_obj.nil? or _existing_user_obj.blank? then

            begin
              _user_obj = create_user_obj(user_obj.email.downcase,status_check(user_obj.status),user_obj.encrypted_password,
                user_obj.profile.first_name,user_obj.profile.last_name,
                user_obj.profile.city,user_obj.profile.state,
                user_obj.profile.postal_code,user_obj.profile.country,
                user_obj.profile.phone,user_obj.profile.gender,
                user_obj.profile.birthday,user_obj.profile.income,
                user_obj.profile.net_worth,user_obj.profile.education,
                user_obj.profile.bio,user_obj.profile.marital_status,
                user_obj.profile.suite,user_obj.profile.middle_name,
                user_obj.profile.full_name,
                user_obj.created_at,user_obj.updated_at,title,company,_expertise_list,_interest_list,str_name.chop
              )

              p "User #{_user_obj.id} saved."
              USER_PROFILE_LOG.info "#{_user_obj.id}.#{_user_obj.email} saved."
            rescue
              p "The User Raised exceptions."
              USER_PROFILE_LOG.info "The User Raised exception"
            end
          else
            p "The User #{_existing_user_obj.email} existing in the new database."
            USER_PROFILE_LOG.info "The User #{_existing_user_obj.email} existing in the new database."
          end

        else
          p "The User #{user_obj.email} Is Invited in the exisiting DB."
          USER_PROFILE_LOG.info "The User #{user_obj.email} Is Invited in the exisiting DB."
        end
      else
        p "The User #{user_obj.email} Is not having password."
        USER_PROFILE_LOG.info "The User #{user_obj.email} Is not having password."
      end
    end

  end
end




