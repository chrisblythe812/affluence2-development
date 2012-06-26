class AddColumnsTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :token, :string, :limit => 40
    add_column :users, :token_expiration_date, :datetime
    add_index :users, :token, :unique => true
  end
end
