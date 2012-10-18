class BrainTreeTranscation < ActiveRecord::Base

  def self.event_payment(payable_promotion)
   # todo need to check past payment by this user to event was success or not.
   # if pastpayment was failure?
   # if past payment was success?
   # if user wants to but few more tickets ?
   # if user wants to cancel the registration?
    payment = PayablePromotion.pending_payment(payable_promotion)
    if !payment.blank?
      result = BrainTreeTranscation.do_payments_by_compare_local_and_remote_trans(payment)
    else
      payment = create_payment_object(payable_promotion)
      result = BrainTreeTranscation.s2s_transaction(payment,payable_promotion)
      respond_with_result(payment,result)


    end
  end


  def self.make_payment(subscription)
    if !subscription.past_payment.blank? && (subscription.past_payment.status == 'pending' || subscription.past_payment.status == 'failed')
      result = BrainTreeTranscation.make_payments_for_old_transactions(subscription)
    elsif !subscription.past_payment.blank? && subscription.past_payment.status == 'completed'
      # happens when the schedular crashed before updating to SFT
      PaymentLog.create(:payment_id => subscription.past_payment.id, :info=> 9 , :log_level => 1 )
      result = 'success'
    else
      result = BrainTreeTranscation.new_transaction(subscription)
    end
    result
  end


  def self.make_payments_for_old_transactions(subscription)
       if  subscription.past_payment.status == 'pending'
        result = BrainTreeTranscation.do_payments_by_compare_local_and_remote_trans(subscription.past_payment)
      elsif subscription.past_payment.status == 'failed'
        PaymentLog.create(:payment_id => subscription.past_payment.id, :info=> 8 , :log_level => 1 )
        result = BrainTreeTranscation.s2s_transaction(subscription.past_payment,subscription)
        respond_with_result(subscription.past_payment,result)
      end
  end



  def self.do_payments_by_compare_local_and_remote_trans(payment)
    PaymentLog.create(:payment_id => payment.id, :info=> 4 , :log_level => 1 )
    local_bt_trans = self.local_bt_search(payment.uuid)
    remote_bt_trans = self.remote_bt_search(payment.uuid)
    if remote_bt_trans.blank?
      PaymentLog.create(:payment_id => payment.id, :info=> 5 , :log_level => 1 )
      result = BrainTreeTranscation.s2s_transaction(payment,'subscription')
      respond_with_result(payment,result)
    elsif self.records_differ?(local_bt_trans,remote_bt_trans)
      PaymentLog.create(:payment_id => payment.id, :info=> 6 , :log_level => 1 )
      self.create_missing_transactions(remote_bt_trans,payment,'subscription')
      respond_with_last_transaction(payment)
    else
      respond_with_last_transaction(payment)
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
       PaymentLog.create(:payment_id => payment.id, :info=> 7 , :log_level => 1 )
       return result
     else
       payment.update_attribute(:status, "failed")
       PaymentLog.create(:payment_id => payment.id, :info=> 7 , :log_level => 3 )
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






   def self.create_payment_object(payment_object)
     uuid =  "#{payment_object.class.name}_#{UUID.new.generate}"
     puts "Created new payment transaction with uuid - #{uuid}"
     payment = Payment.new(:user_id => payment_object.user_id,
                           :braintree_customer_id => payment_object.user.braintree_customer_id,
                           :amount =>  payment_object.amount,
                           :payable_id => payment_object.id,
                           :payable_type => payment_object.class.name,
                           :uuid => uuid,
                           :trails_count => 1)
     payment.save
     PaymentLog.create(:payment_id => payment.id, :info=> 1 , :log_level => 1 )
     return payment
   end





  def self.save_transcation(transaction,payment,result='success')
    if result == 'success'
    local_bt_transcation = BrainTreeTranscation.create(
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
    PaymentLog.create(:payment_id => payment.id, :brain_tree_transcation_id => local_bt_transcation.id,  :info=> 3 , :log_level => 1 )
    else
      BrainTreeTranscation.create(
          :payment_uuid =>  payment.uuid,
          :transaction_id  => '',
          :amount  => '',
          :status  => 'failed',
          :complete_result => transaction
      )
      PaymentLog.create(:payment_id => payment.id, :info=> 3 , :log_level => 3 )
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
     self.save_transcation(transaction,past_payment,'success')
   end
 end


  def self.do_transaction_for_failed_payment(past_payment,subscription)
      s2s_transaction(past_payment,subscription)
  end


  def self.s2s_transaction(payment,subscription)
    PaymentLog.create(:payment_id => payment.id, :info=> 2 , :log_level => 1 )
    BrainTreeTranscation.transaction do
        result = Braintree::Transaction.sale(
                                            :amount => payment.amount,
                                            :customer_id => payment.braintree_customer_id,
                                            :order_id => payment.uuid,
                                            :options => {:submit_for_settlement => true}
                                            )
          if result.success? &&  result.transaction.status == 'submitted_for_settlement'
            self.save_transcation(result.transaction,payment,'success')
            return 'success'
          else
            self.save_transcation(result.errors,payment,'failed')
            return 'failed'
          end
      end
  end


end
