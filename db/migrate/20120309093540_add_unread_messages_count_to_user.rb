class AddUnreadMessagesCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :unread_messages_counter, :integer, :default => 0
  end
end
