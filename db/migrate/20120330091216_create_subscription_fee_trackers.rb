class CreateSubscriptionFeeTrackers < ActiveRecord::Migration
  def change
    create_table :subscription_fee_trackers do |t|
      t.integer  "user_id"
      t.date "renewal_date"
      t.integer "amount"
      t.string "status", :default => 'pending'
      t.timestamps
    end
  end
end
