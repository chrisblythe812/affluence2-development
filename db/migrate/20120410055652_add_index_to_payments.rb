class AddIndexToPayments < ActiveRecord::Migration
  def change
    add_index :payments, :user_id, :name => "index_payments_on_user_id"
    add_index :payments, [:payable_type, :payable_id], :name => "index_payments_on_payable"
    add_index :payments, :uuid, :name => "index_payments_on_uuid"
  end
end
