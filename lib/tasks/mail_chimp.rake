require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'active_support'
require 'action_pack'
require 'hominid'


namespace :affluence do
  desc "This will dump Affluenece production data into Affluence2."
  task :mail_chimp_dumper => :environment do
    puts "Rake Started.."

    User.find(:all,:conditions => "status = 'active' and id >= 2", :order => 'ID ASC').each do | user_obj |
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





