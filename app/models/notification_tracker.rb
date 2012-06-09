class NotificationTracker < ActiveRecord::Base

  belongs_to :user
  belongs_to :notifiable, :polymorphic => true


  def self.schedule_event_emails(user,event)
    event_notification_on_successful_registration(user,event)
    schedule_event_reminders(user,event)
  end


  def self.schedule_event_reminders(user,event)
    Event::EMAIL_REMINDER_SCHEDULE_INTERVAL_DAYS.each do |day|
      if (event.start_date-day) > Date.today
        schedule_date = event.start_date-day
        create_event_notification(user,event,schedule_date,2)
      end
    end
  end

  def self.event_notification_on_successful_registration(user,event)
    create_event_notification(user,event,Date.today,1)
  end


  def self.create_event_notification(user,event,date,mode)
    create(:user_id => user.id,:channel => 'email', :subject => "Event",
           :status => 'pending',:notifiable_id => event.id, :notifiable_type => 'Event',
           :notifiable_mode => mode,:scheduled_date => date)
  end


  def self.subscription_notification_on_success_payment(subscription)
    self.create_subscription_notification(subscription,"Payment success notification",1,Date.today,'email')
  end

  def self.subscription_notification_on_failure_payment(subscription)
    create_subscription_notification(subscription,"Payment failure notification",2,Date.today,'email')
    create_alert_notification(subscription,"Payment failure notification",2,Date.today,'alert')
  end


  def self.create_subscription_notification(subscription,subject,mode,date,channel)
    create(:user_id => subscription.user_id, :channel => channel, :subject => subject,
           :notifiable_id => subscription.id, :notifiable_type => 'SubscriptionFeeTracker', :notifiable_mode => mode,
           :status => 'pending',
           :scheduled_date => date)
  end


  def self.send_email_notification(notifications)
    if !notifications.blank?
      notifications.each do |notify|
        notify_through_email(notify)
      end
    end
  end


  def self.notify_through_email(notification_tracker)
    begin
    if  notification_tracker.notifiable_type == 'Event'
    notifier_method = Event::EMAIL_NOTIFICATION_METHODS[notification_tracker.notifiable_mode]
    Notifier.send("#{notifier_method}",notification_tracker).deliver
    elsif notification_tracker.notifiable_type == 'SubscriptionFeeTracker'
      notifier_method = SubscriptionFeeTracker::EMAIL_MODE_METHODS[notification_tracker.notifiable_mode]
      Notifier.send("#{notifier_method}",notification_tracker).deliver
    elsif notification_tracker.notifiable_type == 'Connection'
      puts 'inside notification of Connection'
      Notifier.send('new_connection_email',notification_tracker.notifiable).deliver
    elsif notification_tracker.notifiable_type == 'Message'
      puts 'inside notification of message'
      Notifier.send('new_message_email',notification_tracker.notifiable).deliver
    end
    #puts "inside updating notification record to as completed-#{notification_tracker.id}"
    notification_tracker.update_attributes(:status => 'completed')
    rescue
    puts "-----------failed for notification_tracker #{notification_tracker.id}------------- "
    end

  end

end
