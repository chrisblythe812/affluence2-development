namespace :affluence2 do
  desc "This will do the payments for subscribed users"
  task :do_subscriptions => :environment do


    actual_subscriptions = SubscriptionFeeTracker.find(:all,
    :conditions => ["status like ? AND renewal_date = ? AND retry_count <= ? AND retry_date is NULL",'pending',Date.today,3])

    SubscriptionFeeTracker.do_subscriptions(actual_subscriptions)

    failed_subscriptions = SubscriptionFeeTracker.find(:all,
    :conditions => ["status like ? AND retry_date = ? AND retry_count <= ? ",'failed',Date.today,3])

    SubscriptionFeeTracker.do_subscriptions(failed_subscriptions)



  end

end





