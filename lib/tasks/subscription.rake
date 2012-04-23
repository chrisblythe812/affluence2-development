namespace :affluence2 do
  desc "This will do the payments for subscribed users"
  task :do_subscriptions => :environment do


     actual_subscriptions = SubscriptionFeeTracker.where(
        :renewal_date => (Date.today-6)..(Date.today),
        :status => 'pending',
        :retry_count => 0..3,
        :retry_date => NIL )

    SubscriptionFeeTracker.do_subscriptions(actual_subscriptions)




     failed_subscriptions = SubscriptionFeeTracker.where(
         :status => 'failed',
         :retry_count => 0..3,
         :retry_date => Date.today)

     SubscriptionFeeTracker.do_subscriptions(failed_subscriptions)

    #todo convert the poeple who are out of freetrails and payment was failed, convert them to free from paid and notify them with email.


  end

  desc "This will send emails to all the records that were created in notification trackers"
  task :email_notifications => :environment do

   notifications =  NotificationTracker.where(
       :scheduled_date => (Date.today-6)..(Date.today),
       :status => 'pending'
   )
   NotificationTracker.send_email_notification(notifications)


  end

end





