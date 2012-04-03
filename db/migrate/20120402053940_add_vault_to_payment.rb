class AddVaultToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :braintree_customer_id, :string
    add_column :payments, :payment_method_token, :string
  end
end
