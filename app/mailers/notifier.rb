class Notifier < ActionMailer::Base
  default from: "support@affluence.org"

  def event_registration(notification_tracker)
    mail( :to => notification_tracker.user.email,
          :subject => 'event registration' )
  end


  def event_reminder(notification_tracker)
    mail( :to => notification_tracker.user.email,
          :subject => 'event reminder' )
  end


  def subscription_success(subscription)
    mail( :to => notification_tracker.user.email,
          :subject => 'subscription success' )
  end


  def subscription_failure(subscription)
    mail( :to => notification_tracker.user.email,
          :subject => 'subscription failure' )
  end

end
