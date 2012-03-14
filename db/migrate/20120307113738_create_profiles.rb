class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer  "user_id"
      t.string   "city"
      t.string   "state"
      t.string   "country"
      t.string   "phone"
      t.text     "bio"
      t.string   "title"
      t.string   "company"
      t.string   "picture_file_name"
      t.string   "picture_content_type"
      t.integer  "picture_file_size"
      t.datetime "picture_updated_at"
      t.string   "last_name"
      t.string   "middle_name"
      t.string   "first_name"
      t.string   "full_name"
      t.timestamps
    end
    add_index "profiles", ["full_name"], :name => "index_profiles_on_full_name"
    add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  end
end
