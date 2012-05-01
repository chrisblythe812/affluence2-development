class SubscriptionFeeTracker < ActiveRecord::Base

  belongs_to :user

  RETRIES = 3
  INTERVALS = 2


  EMAIL_MODES = {1 => 'subscription_success',
                 2 => 'subscription_failure',
  }

  EMAIL_MODE_METHODS = { 1 => 'subscription_success',
                         2 => 'subscription_failure',


  }



  scope :pending, :conditions => {:status => 'pending'}
  scope :failed, :conditions => {:status => 'failed'}
  scope :not_completed, :conditions => ["status like 'pending' OR status like 'failed'"]





  def self.do_subscriptions(subscriptions)
    if !subscriptions.blank?
      puts "Found #{subscriptions.size} subscriptions "
      subscriptions.each do |subscription|
        puts "Making transaction for subscription : #{subscription.id} "
        make_payment_for_subscription(subscription)
      end
    end
  end


  def self.make_payment_for_subscription(subscription)
    result = BrainTreeTranscation.make_payment(subscription)
    if result == 'success'
      subscription.update_attribute(:status, "completed")
      create_next_billing_record(subscription)
      NotificationTracker.subscription_notification_on_success_payment(subscription)
    elsif result == 'failed'
      subscription.update_with_number_of_trails_left
      NotificationTracker.subscription_notification_on_failure_payment(subscription)
    end
    return result
  end



  def update_with_number_of_trails_left
    subscription_params = {:retry_date =>  self.renewal_date+calculate_renewal_date(self.retry_count),
    :retry_count => self.retry_count+1,
    :status => "failed"}
    puts "Update the subscription with params:#{subscription_params}"
    self.update_attributes(subscription_params)
    #todo when retry_count = 3 then need to update
  end

  def calculate_renewal_date(retry_count)
   return INTERVALS if retry_count == 0
   return INTERVALS+2 if retry_count == 1
   return INTERVALS+4 if retry_count == 2
  end


  def self.create_next_billing_record(subscription)
    next_billing_date = calculate_next_billing_date(subscription)
    SubscriptionFeeTracker.create(:user_id => subscription.user_id,:renewal_date =>next_billing_date,:amount =>subscription.user.plan_amount)
  end

  def self.calculate_next_billing_date(subscription)
   actual_bill_date =  subscription.renewal_date
   days_to_add =  subscription.user.plan_period_in_days
   next_billing_date =  actual_bill_date+days_to_add
  end


  def has_last_payment?
    if !pending_payment.blank?  && (pending_payment.status == 'pending' || pending_payment.status == 'failed')# they may be failed or pending records
      puts "Found #{pending_payments.size} pending/failed payments"
      return true
    else
      puts "No pending payments"
      return false
    end
  end


  def past_payment
    Payment.where(:payable_id => id, :payable_type => 'SubscriptionFeeTracker').last
  end

   def self.schedule(user)
     create(:user_id => user.id,:renewal_date => Date.today, :amount => user.plan_amount )
   end




end
