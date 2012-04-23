class AddPolymorphicNotificationTracker < ActiveRecord::Migration
  def up
    add_column :notification_trackers, :notifiable_id, :integer
    add_column :notification_trackers, :notifiable_type, :string
  end

  def down
    remove_column :notification_trackers, :notifiable_id, :integer
    remove_column :notification_trackers, :notifiable_type, :string
  end
end
