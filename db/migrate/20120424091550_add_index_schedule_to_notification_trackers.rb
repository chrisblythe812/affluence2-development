class AddIndexScheduleToNotificationTrackers < ActiveRecord::Migration
  def change
    add_index :notification_trackers, :scheduled_date, :name => "index_notification_trackers_on_scheduled_date"
  end
end
