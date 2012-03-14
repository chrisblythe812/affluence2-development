class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.text     "body"
      t.integer  "user_id"
      t.references :resource, :polymorphic => true
      t.timestamps
    end
  end
end
