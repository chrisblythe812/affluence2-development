class NotificationTracker < ActiveRecord::Base

  belongs_to :user
  belongs_to :notifiable, :polymorphic => true

  def self.event_notification_on_successful_registration(user,event)
   notification_tracker = create(:user_id => user, :channel => 'email', :subject => "Successfull event registration(Test email)",
          :body => "Successfull event registration",:status => 'pending',
          :notifiable_id => event.id, :notifiable_type => 'Event',
          :scheduled_date => Date.today)

  end


  def self.subscription_notification_on_failure_payment(subscription)
    subject = "Payment failure notification"
    body = "Payment failure notification for the user"
    params = {:user_id => subscription.user_id, :channel => 'email', }
   create(:user_id => user, :channel => 'email', :subject => subject, :notifiable_id => subscription.id, :notifiable_type => 'SubscriptionFeeTracker',
         :status => 'pending',
         :scheduled_date => Date.today )
   end


  def self.subscription_notification_on_success_payment(subscription)
    subject = "Payment success notification"
    body = "Payment success notification for the user"
    params = {:user_id => subscription.user_id, :channel => 'email', }
    create(:user_id => user, :channel => 'email', :subject => subject, :notifiable_id => subscription.id, :notifiable_type => 'SubscriptionFeeTracker',
           :status => 'pending',:scheduled_date => Date.today )
  end


  def self.send_email_notification(notifications)
    if !notifications.blank?
      #puts "#{notifications.inspect}"
      notifications.each do |notify|
        notify_through_email(notify)
      end
    end
  end


  def self.notify_through_email(notification_tracker)
    Notifier.event_registration(notification_tracker).deliver
    notification_tracker.update_attributes(:status => 'completed')
  end

end
