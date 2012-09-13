class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.binary :emails_list
      t.string :provider
      t.integer :user_id
      t.timestamps
    end
  end
end
