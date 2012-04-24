class AddColumnScheduledDateToNotificationTrackers < ActiveRecord::Migration
  def change
    add_column :notification_trackers, :scheduled_date, :date
  end
end
