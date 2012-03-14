class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer  "friend_id",  :null => false
      t.integer  "user_id",    :null => false
      t.timestamps

    end
  add_index "connections", ["friend_id", "user_id"], :name => "index_connections_on_friend_id_and_user_id"
  add_index "connections", ["friend_id"], :name => "index_connections_on_friend_id"
  add_index "connections", ["user_id", "friend_id"], :name => "index_connections_on_user_id_and_friend_id"
  add_index "connections", ["user_id"], :name => "index_connections_on_user_id"

  end
end
