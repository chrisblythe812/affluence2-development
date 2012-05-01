class CreateIncludes < ActiveRecord::Migration
  def change
    create_table :includes do |t|
      t.string :title
      t.integer :event_id

      t.timestamps
    end
  end
end
