class AddColumnNotifiableBehaviourToNotificationTrackers < ActiveRecord::Migration
  def change
    add_column :notification_trackers, :notifiable_mode, :integer
  end
end
