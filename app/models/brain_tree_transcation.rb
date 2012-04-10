class BrainTreeTranscation < ActiveRecord::Base



  def self.make_payment(subscription)
    if !subscription.last_payment.blank? && (subscription.last_payment.status == 'pending' || subscription.last_payment.status == 'failed')
      result = BrainTreeTranscation.make_payments_for_old_transactions(subscription)
    elsif !subscription.last_payment.blank? && subscription.last_payment.status == 'completed'
      puts "last payment was success. Update the subscription to success payment"
      result = 'success'
    else
      result = BrainTreeTranscation.new_transaction(subscription)
    end
    result
  end


  def self.make_payments_for_old_transactions(subscription)
    #past_payments.each do |past_payment|
      if  subscription.last_payment.status == 'pending'
        result = BrainTreeTranscation.do_payments_by_compare_local_and_remote_trans(subscription)
      elsif subscription.last_payment.status == 'failed'
        result = BrainTreeTranscation.s2s_transaction(subscription.last_payment,subscription)
        respond_with_result(subscription.last_payment,result)
      else
        puts "payment status is failed. This may due to insufficient funds in last transaction"
        puts "Do the S2S transcation again"
      end

    #end
  end



  def self.do_payments_by_compare_local_and_remote_trans(subscription)
    local_bt_trans = self.local_bt_search(subscription.last_payment.uuid)
    remote_bt_trans = self.remote_bt_search(subscription.last_payment.uuid)

    if remote_bt_trans.blank?
      puts "Remote Transaction was missing "
      result = BrainTreeTranscation.s2s_transaction(subscription.last_payment,subscription)
      respond_with_result(subscription.last_payment,result)
    elsif self.records_differ?(local_bt_trans,remote_bt_trans)
      puts "Found difference in records"
      self.create_missing_transactions(remote_bt_trans,subscription.last_payment,subscription)
      respond_with_last_transaction(subscription.last_payment)
    else
      respond_with_last_transaction(subscription.last_payment)
    end
  end









  def self.new_transaction(subscription)
     if (!subscription.user.blank? &&  !subscription.user.braintree_customer_id.blank?)
       payment = create_payment_object(subscription)
       result = BrainTreeTranscation.s2s_transaction(payment,subscription)
       respond_with_result(payment,result)
      end

   end


   def self.respond_with_result(payment,result)
     if result == 'success'
       payment.update_attribute(:status,"completed")
       puts "respond_with_result as success"
       return result
     else
       payment.update_attribute(:status, "failed")
       puts "respond_with_result as failed"
       return result
     end
   end

  def self.respond_with_last_transaction(payment)
    last_trans = BrainTreeTranscation.find(:last,:conditions => ["payment_uuid like ?",payment.uuid])
    if last_trans.status == 'submitted_for_settlement'
      respond_with_result(payment,'success')
    else
      respond_with_result(payment,'failed')
    end
  end






   def self.create_payment_object(subscription)
     uuid =  "SubscriptionFeeTracker_#{UUID.new.generate}"
     puts "Created new payment transaction with uuid - #{uuid}"
     payment = Payment.new(:user_id => subscription.user_id,
                           :braintree_customer_id => subscription.user.braintree_customer_id,
                           :amount =>  subscription.amount,
                           :payable_id => subscription.id,
                           :payable_type => 'SubscriptionFeeTracker',
                           :uuid => uuid,
                           :trails_count => 1)
     payment.save
     return payment
   end






















  def self.save_transcation(transaction,payment,result='success')
    if result == 'success'
    BrainTreeTranscation.create(
        :payment_uuid =>  payment.uuid,
        :transaction_id  => transaction.id,
        :amount  => transaction.amount,
        :status  => transaction.status,
        :customer_id   => transaction.customer_details.id,
        :customer_first_name  => transaction.customer_details.first_name,
        :customer_email   => transaction.customer_details.email,
        :credit_card_token   => transaction.credit_card_details.token,
        #:credit_card_bin  => transaction.credit_card_details.bin,
        #:credit_card_last_4   => transaction.credit_card_details.last_4,
        #:credit_card_card_type     => transaction.credit_card_details.card_type,
        #:credit_card_expiration_date     => transaction.credit_card_details.expiration_date,
        #:credit_card_cardholder_name     => transaction.credit_card_details.cardholder_name,
        #:credit_card_customer_location       => transaction.credit_card_details.customer_location,
        #:complete_result          => complete_result,
    )
    else
      BrainTreeTranscation.create(
          :payment_uuid =>  payment.uuid,
          :transaction_id  => '',
          :amount  => '',
          :status  => 'failed',
          :complete_result => transaction
      )
    end

    end










  def self.remote_bt_search(uuid)
    Braintree::Transaction.search do |search|
      search.order_id.is "#{uuid}"
    end
  end


  def self.local_bt_search(uuid)
    BrainTreeTranscation.where(payment_uuid: uuid)
  end

   def self.records_differ?(local_bt_trans,remote_bt_trans)
    remote_records_size = !remote_bt_trans.blank? ? remote_bt_trans.maximum_size.to_i : 0
    local_records_size = !local_bt_trans.blank? ? local_bt_trans.size.to_i : 0
    puts "remote_records_size : #{remote_records_size}, local_records_size : #{local_records_size}"
    if remote_records_size != local_records_size
      return true
    else
      return false
    end
   end

 def self.create_missing_transactions(remote_bt_trans,past_payment,subscription)
   puts "Creating missing records"
   remote_bt_trans.each do |transaction|
     self.save_transcation(transaction,past_payment)
   end
 end


  def self.do_transaction_for_failed_payment(past_payment,subscription)
      s2s_transaction(past_payment,subscription)
  end


  def self.s2s_transaction(payment,subscription)
    BrainTreeTranscation.transaction do
        result = Braintree::Transaction.sale(
                                            :amount => payment.amount,
                                            :customer_id => payment.braintree_customer_id,
                                            :order_id => payment.uuid,
                                            :options => {:submit_for_settlement => true}
                                            )
          if result.success? &&  result.transaction.status == 'submitted_for_settlement'
            self.save_transcation(result.transaction,payment,'success')
            puts "Got the success response from braintree"
            return 'success'
            puts "Need to create next billing cycle."
          else
            self.save_transcation(result.errors,payment,'failed')
            puts "Got failure response from braintree"
            return 'failed'
          end
      end
  end


end