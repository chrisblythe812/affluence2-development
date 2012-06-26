class CreateAccessGrants < ActiveRecord::Migration
  def change
    create_table :access_grants do |t|
      t.string :token, :limit => 40
      t.string :refresh_token, :limit => 40
      t.datetime :access_token_expires_at
      t.integer :user_id
      t.integer :client_application_id
      t.timestamps
    end
    add_index :access_grants, :token, :unique => true

  end
end
