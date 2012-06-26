class CreateClientApplications < ActiveRecord::Migration
  def change
    create_table :client_applications do |t|
      t.string :name
      t.string :application_key, :limit => 40
      t.string :secret, :limit => 40
      t.string :callback_url
      t.timestamps
    end
    add_index :client_applications, :application_key, :unique => true
  end
end
