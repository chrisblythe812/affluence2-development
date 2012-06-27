require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'

#TODO : Timestamps needs to be replaced.
#Paramalink fix for polish chars : needs to be tested.

def get_users_from_old_db
  User.all
end

def put_users_to_new_db
  

end

def create_user_obj(email,status,encrypted_password,first_name,last_name,
    city,state,postal_code,country,phone,gender,birthday,
    income,net_worth,education,bio,marital_status,
    suite,middle_name,full_name,invitation_source
  )
  p email
  p first_name
  p last_name

 
  connect_to_new_db
  _u = User.new(:email => email,:status => status, :password => encrypted_password, :plan => 'free')
  p User.column_names
  p first_name
  p last_name
  p city
  p country
  _u.build_profile(:first_name => first_name, :last_name => last_name,
    :city => city, :state => state, :country => country,
    :phone => phone, :bio => bio, :middle_name => middle_name,
    :full_name => full_name, :invitation_source => invitation_source)
  _u.save!
  _u.update_attribute('encrypted_password', encrypted_password)
  
end

def connect_to_old_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "vegpuf",
    :database => "affluence_development"
  )
end

def connect_to_new_db
  ActiveRecord::Base.establish_connection(
    :adapter  => "postgresql",
    :host     => "localhost",
    :username => "postgres",
    :password => "vegpuf",
    :database => "affluence2_development"
  )
end

namespace :affluence do
  desc "This will dump Affluenece production data into Affluence2."
  task :user_profile_data_dumper => :environment do
    puts "Rake Started.."

    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy
      connect_to_old_db
    end

   
    ActiveRecord::Base.logger = Logger.new(STDERR)

    ProdUser.find(:all,:conditions => "id = 4491").each do | user_obj |
      #user_obj = ProdUser.find_by_id(40209)
      connect_to_old_db
      
      if (user_obj.status != 'invited')
        if (user_obj.status != 'denied')
          p "in looooooooooooooooop#{user_obj.status}"
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

          p user_obj.status
      
          connect_to_new_db
          _existing_user_obj = User.find_by_email(user_obj.email)
      
          if _existing_user_obj.nil? or _existing_user_obj.blank? then
            p user_obj.inspect
            p user_obj.profile.inspect
            create_user_obj(user_obj.email,user_obj.status,user_obj.encrypted_password,
              user_obj.profile.first_name,user_obj.profile.last_name,
              user_obj.profile.city,user_obj.profile.state,
              user_obj.profile.postal_code,user_obj.profile.country,
              user_obj.profile.phone,user_obj.profile.gender,
              user_obj.profile.birthday,user_obj.profile.income,
              user_obj.profile.net_worth,user_obj.profile.education,
              user_obj.profile.bio,user_obj.profile.marital_status,
              user_obj.profile.suite,user_obj.profile.middle_name,
              user_obj.profile.full_name,user_obj.profile.invitation_source
            )
          else
            p "The User #{_existing_user_obj.email} existing in the new database."
          end
        else
          p "The User #{user_obj.email} Is Denied in the exisiting DB."
        end
      else
        p "The User #{user_obj.email} Is Invited in the exisiting DB."
      end
    end
    
  end
end





