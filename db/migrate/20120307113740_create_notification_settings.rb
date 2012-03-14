class CreateNotificationSettings < ActiveRecord::Migration
  def change
    create_table :notification_settings do |t|
    t.integer  "profile_id", :null => false
    t.boolean  "newsletter", :default => true
    t.boolean  "offers", :default => true
    t.boolean  "events", :default => true
    t.boolean  "messages", :default => true
    t.boolean  "event_reminders", :default => true
    t.boolean  "site_news", :default => true
      t.timestamps
    end
  add_index "notification_settings", ["profile_id"], :name => "index_notification_settings_on_profile_id"
  end
end
