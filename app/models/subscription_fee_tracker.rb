class SubscriptionFeeTracker < ActiveRecord::Base

  belongs_to :user

  RETRIES = 3
  INTERVALS = 2


  def self.do_subscriptions(subscriptions)
    if !subscriptions.blank?
      puts "Found #{subscriptions.size} subscriptions "
      subscriptions.each do |subscription|
        puts "Making transaction for subscription : #{subscription.id} "
        result = BrainTreeTranscation.make_payment(subscription)
        if result == 'success'
          subscription.update_attribute(:status, "completed")
          create_next_billing_record(subscription)
        elsif result == 'failed'
          # todo need to send email notification to user
          # todo create record in notification_trackers
          subscription.update_with_number_of_trails_left
        end

      end
    end
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



end
