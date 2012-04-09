class Payment < ActiveRecord::Base


  belongs_to :user

   def  self.do_transcation(subscription)
     if subscription.has_pending_payments?
       result = Payment.make_payments_for_old_transactions(subscription.pending_payments,subscription)
     else
       result = Payment.new_transaction(subscription)
     end

     if result == 'success'
       payment.update_attribute(:status,"completed")
       return 'success'
     else
       payment.update_attribute(:status, "failed")
       return 'failed'
     end
   end




  def self.new_transaction(subscription)
    if (!subscription.user.blank? &&  !subscription.user.braintree_customer_id.blank?)
      uuid =  "SubscriptionFeeTracker_#{UUID.new.generate}"

      payment = Payment.new(:user_id => subscription.user_id,
                            :braintree_customer_id => subscription.user.braintree_customer_id,
                            :amount =>  subscription.amount,
                            :payable_id => subscription.id,
                            :payable_type => 'SubscriptionFeeTracker',
                            :uuid => uuid,
                            :trails_count => 1)

      if payment.save
        puts "Created new payment transaction with uuid - #{uuid}"
        result = BrainTreeTranscation.s2s_transaction(payment,subscription)
        return result
      end
        return 'failed'
    end
        return 'failed'
  end


  def self.make_payments_for_old_transactions(past_payments,subscription)

    past_payments.each do |past_payment|

      if  past_payment.status == 'pending'
        BrainTreeTranscation.do_payments_by_compare_local_and_remote_trans(past_payment,subscription)
      elsif past_payment.status == 'failed'
        BrainTreeTranscation.do_transaction_for_failed_payment(past_payment,subscription)
      else
        puts "payment status is failed. This may due to insufficient funds in last transaction"
        puts "Do the S2S transcation again"
      end
    end
  end


end
