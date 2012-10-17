class CreateConciergeRequests < ActiveRecord::Migration
  def change
    create_table :concierge_requests do |t|
      t.integer :operator_id
      t.integer :user_id
      t.text :request_note
      t.text :todo
      t.timestamps
    end
  end
end
