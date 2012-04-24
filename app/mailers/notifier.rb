class Notifier < ActionMailer::Base
  default from: "support@affluence.org"

  def event_registration(notification_tracker)
    mail( :to => notification_tracker.user.email,
          :subject => notification_tracker.subject )
  end
end
