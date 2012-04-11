class CreateNotificationTrackers < ActiveRecord::Migration
  def change
    create_table :notification_trackers do |t|
      t.integer :user_id
      t.string :channel
      t.string :subject
      t.text :body
      t.string :status, :default => 'pending'
      t.timestamps
    end
    add_index :notification_trackers, :user_id, :name => 'index_notification_trackers_on_user_id'
  end
end
