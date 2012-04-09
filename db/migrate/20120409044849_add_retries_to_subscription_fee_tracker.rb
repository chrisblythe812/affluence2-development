class AddRetriesToSubscriptionFeeTracker < ActiveRecord::Migration
  def change
    add_column :subscription_fee_trackers, :retry_date, :date
    add_column :subscription_fee_trackers, :retry_count, :integer, :default => 0
  end
end
