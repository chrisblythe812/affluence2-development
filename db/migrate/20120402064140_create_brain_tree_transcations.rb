class CreateBrainTreeTranscations < ActiveRecord::Migration
  def change
    create_table :brain_tree_transcations do |t|
      t.string :payment_uuid
      t.string :transaction_id
      t.string :amount
      t.string :status
      t.string :customer_id
      t.string :customer_first_name
      t.string :customer_email
      t.string :credit_card_token
      t.string :credit_card_bin
      t.string :credit_card_last_4
      t.string :credit_card_card_type
      t.string :credit_card_expiration_date
      t.string :credit_card_cardholder_name
      t.string :credit_card_customer_location
      t.text :complete_result
      t.timestamps
    end
  end
end
