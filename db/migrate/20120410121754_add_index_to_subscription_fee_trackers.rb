class AddIndexToSubscriptionFeeTrackers < ActiveRecord::Migration
  def change
    add_index :subscription_fee_trackers, :renewal_date, :name => "index_subscription_fee_trackers_on_renewal_date"
  end
end
