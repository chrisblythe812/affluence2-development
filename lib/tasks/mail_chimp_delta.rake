require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'
require 'hominid'


namespace :affluence do
  desc "This will dump Affluenece production data into Affluence2."
  task :mail_chimp_delta_dumper, :start, :end, :needs => :environment do |t, args|

    p "hi #{args[:start]}"
    p "hi #{args[:end]}"
    puts "Rake Started.."

    User.find(:all,:conditions => "status = 'active' and created_at > '#{args[:start]}' and created_at <= '#{args[:end]}'", :order => 'ID ASC').each do | user_obj |
     begin
      p "The User #{user_obj.email} "
      MailChimp.add_user(user_obj)
      MAILCHIMP_LOG.info "The User #{user_obj.email} added to mail chimp."
     rescue
       p "The User #{user_obj.email} is nto added"
       MAILCHIMP_LOG.info "The User #{user_obj.email} NOT ADDED."
     end
    end
  end

end





