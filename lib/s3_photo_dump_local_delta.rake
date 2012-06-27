require 'cgi'
require 'net/https'
require 'rubygems'
require 'open-uri'
require 'paperclip'
require 'base64'


def s3_upload(url, user_email)
  connect_to_new_db
  _user = User.find_by_email(user_email)
  _profile = _user.profile
  _photo = _profile.photos.build

  _file = File.new(url)
  _photo.image = _file
  _profile.save!
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
  task :s3_photo_dump_local_delta , :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"
    puts "Rake Started.."

    class ProdUser < ActiveRecord::Base
      set_table_name :users
      has_one :profile, :foreign_key => 'user_id', :dependent => :destroy
      connect_to_old_db
    end

    #ActiveRecord::Base.logger = Logger.new(STDERR)

    ProdUser.find(:all,:conditions => "created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'",:order => 'ID ASC').each do | user_obj |
      
      unless user_obj.profile.nil? then
        photo_id = user_obj.profile.id
        photo_name = user_obj.profile.picture_file_name

        unless photo_id.nil? or photo_name.nil? then

          connect_to_old_db
      
          if user_obj.status != 'invited' then
            connect_to_new_db
            _existing_user_obj = User.find_by_email(user_obj.email)
            unless _existing_user_obj.nil? then
              #  if _existing_user_obj.profile.picture_file_name.nil? or _existing_user_obj.profile.picture_file_name.blank? then
              if _existing_user_obj.profile.photos.blank?
                path = "/home/seneca/Desktop/profile_picture/"+photo_id.to_s+"/original/"+photo_name.to_s
                next unless File.exist?(path)
                s3_upload(path,_existing_user_obj.email)
                p "Success : #{path}"
                AWS_LOG.info "Success : #{path}"
              else
                p "Error: The User #{_existing_user_obj.email} 's photo in the new DB."
                AWS_LOG.info "Error: The User #{_existing_user_obj.email} 's photo in the new DB."
              end
            end
          else
            p "Error: The User #{user_obj.email} Is INVITED USER in the exisiting DB."
            AWS_LOG.info "Error: The User #{user_obj.email} Is INVITED USER in the exisiting DB."
          end
        end
      end
      connect_to_old_db
    end
  end
end




