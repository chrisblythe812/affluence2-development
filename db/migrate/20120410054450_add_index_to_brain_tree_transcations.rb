class AddIndexToBrainTreeTranscations < ActiveRecord::Migration
  def change
    add_index :brain_tree_transcations, :payment_uuid, :name => "index_brain_tree_transcations_on_payment_uuid"
    add_index :brain_tree_transcations, :transaction_id, :name => "index_brain_tree_transcations_on_transaction_id"
    add_index :brain_tree_transcations, :customer_id, :name => "index_brain_tree_transcations_on_customer_id"
  end
end
