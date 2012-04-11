class CreatePaymentLogs < ActiveRecord::Migration
  def change
    create_table :payment_logs do |t|
      t.integer "payment_id"
      t.integer "brain_tree_transcation_id"
      t.integer "info"
      t.integer "log_level"
      t.timestamps
    end

    add_index :payment_logs, :payment_id, :name => "index_payment_logs_on_payment_id"
    add_index :payment_logs, :created_at, :name => "index_payment_logs_on_created_at"

  end
end


