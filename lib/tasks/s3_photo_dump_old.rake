require 'cgi'
require 'net/https'
require 'rubygems'
require 'open-uri'
require 'paperclip'
require 'base64'


def s3_upload(url, user_email)
  connect_to_new_db
  p "Uploading latest image to S3."
  _user = User.find_by_email(user_email)
  p "Profile Object is #{_user.profile}"


  _profile = _user.profile
  _photo = _profile.photos.build

  open('rajeshwar.png', 'wb') do |file|
    file << open(url).read
  end

  _file = File.new("rajeshwar.png")
  p _file
  _photo.image = _file
  _profile.save!
end



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


namespace :affluence do
  desc "This will dump Affluenece production data into Affluence2."
  task :s3_photo_dump => :environment do
    puts "Rake Started.."

    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy
      connect_to_old_db
    end

    ActiveRecord::Base.logger = Logger.new(STDERR)

    ProdUser.find(:all,:order => 'ID ASC').each do | user_obj |
      
      unless user_obj.profile.nil? then
        photo_id = user_obj.profile.id
        photo_name = user_obj.profile.picture_file_name

        unless photo_id.nil? or photo_name.nil? then

          url = "https://s3.amazonaws.com/affluenece_migration_test/profile_pictures/"+photo_id.to_s+"/original/"+photo_name

          
          connect_to_old_db
      
          if user_obj.status != 'invited' then
            connect_to_new_db
            _existing_user_obj = User.find_by_email(user_obj.email)
            unless _existing_user_obj.nil? then
              if _existing_user_obj.profile.picture_file_name.nil? or _existing_user_obj.profile.picture_file_name.blank? then
                begin
                  s3_upload(url, _existing_user_obj.email)
                  p "Success #{_existing_user_obj.email} : #{url}'"
                  AWS_LOG.info "Success : #{url}"
                rescue
                  p "Forbidden - 403 #{_existing_user_obj.email} : #{url}'"
                  AWS_LOG.info "Forbidden - 403 : #{url}"
                end
              else
                p "Error: The User #{_existing_user_obj.email} : #{url}'s photo in the new DB."
              end
            end
          else
            p "Error: The User #{user_obj.email} : #{url} Is INVITED USER in the exisiting DB."
          end
        end
      end
      connect_to_old_db
    end
  end
end




