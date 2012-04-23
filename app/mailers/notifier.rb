class Notifier < ActionMailer::Base
  default from: "support@affluence.org"

  def event_registration(notification_tracker)
    #mail( :to => notification_tracker.user.email,
          mail( :to => 'umamahesh.seeram@seneca-global.com',
          :subject => notification_tracker.subject )
  end
end
