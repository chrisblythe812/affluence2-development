class CreateMessages < ActiveRecord::Migration
  def change
  create_table "messages", :force => true do |t|
    t.text     "body"
    t.string   "subject"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
      t.timestamps
  end

  end
end
