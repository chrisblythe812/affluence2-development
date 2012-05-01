class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :date
      t.string :time
      t.string :title
      t.integer :event_id

      t.timestamps
    end
  end
end
