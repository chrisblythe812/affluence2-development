class BrainTreeTranscation < ActiveRecord::Base



  def self.save_transcation(transaction,complete_result,payment)

    BrainTreeTranscation.create(
        :payment_uuid =>  payment.uuid,
        :transaction_id  => transaction.id,
        :amount  => transaction.amount,
        :status  => transaction.status,
        :customer_id   => transaction.customer_details.id,
        :customer_first_name  => transaction.customer_details.first_name,
        :customer_email   => transaction.customer_details.email,
        :credit_card_token   => transaction.credit_card_details.token,
        :credit_card_bin  => transaction.credit_card_details.bin,
        :credit_card_last_4   => transaction.credit_card_details.last_4,
        :credit_card_card_type     => transaction.credit_card_details.card_type,
        :credit_card_expiration_date     => transaction.credit_card_details.expiration_date,
        :credit_card_cardholder_name     => transaction.credit_card_details.cardholder_name,
        :credit_card_customer_location       => transaction.credit_card_details.customer_location,
        :complete_result          => complete_result,
    )

  end


end
