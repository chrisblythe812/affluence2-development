class Notifier < ActionMailer::Base
  default from: "support@affluence.org"

  def event_registration(notification_tracker)
    @notification_tracker = notification_tracker
    mail(:to => notification_tracker.user.email,
         :subject => EMAIL_CONTENT['event_registers']['subject'] %{:member_name => @notification_tracker.user.name, :event_title => @notification_tracker.notifiable.title})
  end


  def event_reminder(notification_tracker)
    @notification_tracker = notification_tracker
    mail(:to => notification_tracker.user.email,
         :subject => EMAIL_CONTENT['hours_until_event']['subject'] %{:event_title => @notification_tracker.notifiable.title})
  end


  def subscription_success(subscription)
    #mail(:to => subscription.user.email,
     mail(:to => 'dev@affluence.org',
         :subject => EMAIL_CONTENT['billing']['subject'])
  end


  def subscription_failure(subscription)
    #mail(:to => subscription.user.email,
     mail(:to => 'dev@affluence.org',
         :subject => 'subscription failure')
  end

  def new_connection_email(connection)
    @connection = connection
    mail(:to => connection.user.email,
         :subject => EMAIL_CONTENT['new_connection']['subject'] %{:member_name => @connection.friend.name})
  end

  def new_message_email(message)
    @message = message
    mail(:to => message.recipient.email,
         :subject => EMAIL_CONTENT['new_message']['subject'] %{:member_name => @message.sender.name})
  end

  def verification_accepted(email, message)
    @message = message
    mail(:to => email,
         :subject => 'You have been successfully verified')
  end

  def verification_rejected(email, message)
    @message = message
    mail(:to => email,
         :subject => 'Your verification has been rejected!')
  end


end

