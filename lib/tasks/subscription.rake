namespace :affluence2 do
  desc "This will do the payments for subscribed users"
  task :do_subscriptions => :environment do
    #puts "Find records from SubscriptionFeeTracker which are <= today date and status = 'pending' or status = 'failed'
    subscriptions = SubscriptionFeeTracker.find(:all, :conditions => ["(status like ? OR status like ?) AND renewal_date <= ? ",'pending','failed',Date.today])

    if !subscriptions.blank?
      puts "Today #{subscriptions.size} subscriptions are going to be paid"
      subscriptions.each  do |subs|
          subscription = SubscriptionFeeTracker.find(subs.id)
          puts "Doing transaction for user- #{subscription.user_id},customer_id - #{subscription.user.braintree_customer_id}"
          if !subscription.user.braintree_customer_id.blank?
         puts "Check the failure payments exists for this subscription"
         past_payments = Payment.find(:all, :conditions => ["payable_type = 'SubscriptionFeeTracker' and payable_id = ? and status != 'complete'",subscription.id])

         if !past_payments.blank?
                  puts "found #{past_payments.size} pending/failed payments"

                  past_payments.each do |past_pay|
                    past_payment = Payment.find(past_pay.id)
                    if  past_payment.status == 'pending'
                     puts "payment status is pending, that means we may missed the braintrnsaction."
                     puts "check does we have the braintreetransaction record associated with this payment uuid"
                     braintreetranscation = BrainTreeTranscation.find_by_payment_uuid(past_payment.uuid)
                      if  !braintreetranscation.blank?
                          puts "braintreetranscation exists, check the status of braintreetranscation"
                          puts "braintreetranscation.status : #{braintreetranscation.status}"
                          #puts "if braintree transaction and payment status are not same. update them to match the same."
                          if braintreetranscation.status == 'submitted_for_settlement'
                            puts "update the payment status to completed"
                            past_payment.update_attribute(:status,"completed")
                            puts "update the subscriptionfeetracker status to completed"
                            subscription.update_attribute(:status, "completed")
                            puts "create next billing cycle."
                          else
                            puts "update the payment status to failed"
                            past_payment.update_attribute(:status, "failed")
                            puts "update the subscriptionfeetracker status to failed"
                            subscription.update_attribute(:status, "failed")
                            puts "under the failed satuation. Need to check whether we need to do transaction or not!!"
                          end

                          puts "Do the S2S transcation again"

                      else
                          puts "braintreetranscation record does not exists. Check the transcation with uuid/order_id @ braintree"


                         search_results = Braintree::Transaction.search do |search|
                           search.order_id.is "#{past_payment.uuid}"
                         end

                         if !search_results.blank?
                           puts "transcation #{search_results.maximum_size} were found at braintree. Check those status and record them in braintreetranscation table."

                           search_results.each do |search_result|
                             puts "find each transcation with id"
                             puts "search_result.inspect : #{search_result.inspect}"
                               BrainTreeTranscation.save_transcation(search_result,search_result,past_payment)
                               if search_result.status == 'submitted_for_settlement'
                                 puts "Got the success response from braintree"
                                 puts "update the payment status to completed"
                                 past_payment.update_attribute(:status,"completed")
                                 puts "update the subscriptionfeetracker status to completed"
                                 subscription.update_attribute(:status, "completed")
                                 puts "create next billing cycle."
                               else
                                 puts "Got the failure response from braintree"
                                 puts "update the payment status to failed"
                                 past_payment.update_attribute(:status, "failed")
                                 puts "update the subscriptionfeetracker status to failed"
                                 subscription.update_attribute(:status, "failed")
                               end
                           end

                         else
                           puts "transcation was not found @ braintree. Do the new transcation now."
                           puts "Do the S2S transcation again"
                         end



                      end
                   else
                      puts "payment status is failed. This may due to insufficient funds in last transaction"
                      puts "Do the S2S transcation again"
                   end


                  end # past_payments.each end


         else

                 puts "No past_payments were found. So creating the new payment"
                  payment = Payment.new(:user_id => subscription.user_id,
                          :braintree_customer_id => subscription.user.braintree_customer_id,
                          #:payment_method_token => subscription.user.
                          :amount =>  subscription.amount,
                          :payable_id => subscription.id,
                          :payable_type => 'SubscriptionFeeTracker',
                          :uuid => "#{UUID.new.generate}",
                          :trails_count => 1)


                  if payment.save
                      puts "Created payment record with uuid - #{payment.uuid}"
                      puts "Do S2S transaction"
                      result = Braintree::Transaction.sale(
                          :amount => payment.amount,
                          :customer_id => payment.braintree_customer_id,
                          :order_id => payment.uuid,
                          :custom_fields => {
                              :uuid => payment.uuid
                          },
                          :options => {
                              :submit_for_settlement => true
                          }

                      )

                      puts "save the transaction response in BrainTreeTranscation"
                      BrainTreeTranscation.save_transcation(result.transaction,result,payment)
                    if result.success? &&  result.transaction.status == 'submitted_for_settlement'
                      puts "Got the success response from braintree"
                      puts "update the payment status to completed"
                      payment.update_attribute(:status,"completed")
                      puts "update the subscriptionfeetracker status to completed"
                      subscription.update_attribute(:status, "completed")
                      puts "create next billing cycle."
                    else
                      puts "Got the failure response from braintree"
                      puts "update the payment status to failed"
                      payment.update_attribute(:status, "failed")
                      puts "update the subscriptionfeetracker status to failed"
                      subscription.update_attribute(:status, "failed")
                    end



                  end # payment.save end

         end  # !past_payments.blank? end






          end
      end
    end

  end  
end





