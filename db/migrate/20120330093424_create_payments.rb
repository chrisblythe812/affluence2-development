class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer "user_id"
      t.references :payable, :polymorphic => true
      t.string "status", :default => 'pending'
      t.string "uuid"
      t.integer "trails_count"
      t.string "amount"
      t.timestamps
    end
  end
end
