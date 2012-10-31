class CreateTableTwilioCalls < ActiveRecord::Migration
  def up
    create_table :twilio_calls do |t|
      t.integer :user_id
      t.string :account_sid
      t.string :direction
      t.string :call_sid
      t.string :from_phone_number
      t.string :from_country
      t.string :call_status
      t.string :to_phone_number
      t.string :to_country
      t.string :api_version
      t.string :recording_url
      t.integer :call_duration
      t.integer :recording_duration
      t.string :recording_sid
      t.timestamps
    end
    add_index :twilio_calls, :user_id, :name => 'index_twilio_calls_on_user_id'
    add_index :twilio_calls, :call_sid, :name => 'index_twilio_calls_on_call_sid'
    add_index :twilio_calls, :to_phone_number, :name => 'index_twilio_calls_on_to_phone_number'
  end

  def down
    drop_table :twilio_calls
  end
end
