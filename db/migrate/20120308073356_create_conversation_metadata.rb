class CreateConversationMetadata < ActiveRecord::Migration
  def change
    create_table :conversation_metadata do |t|
      t.integer "conversation_id"
      t.integer "user_id"
      t.boolean "archived"
      t.boolean "read"
      t.timestamps
    end
  end
end
