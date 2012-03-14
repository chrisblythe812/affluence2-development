class CreatePrivacySettings < ActiveRecord::Migration
  def change
    create_table :privacy_settings do |t|
    t.integer  "profile_id", :null => false
    t.integer  "events", :default => 0
    t.integer  "offers", :default => 0
    t.integer  "concierge", :default => 0
    t.integer  "photos", :default => 0
    t.integer  "invitations", :default => 0
    t.integer  "new_contact", :default => 0
      t.timestamps
   end
  add_index "privacy_settings", ["profile_id"], :name => "index_privacy_settings_on_profile_id"
  end
end
  