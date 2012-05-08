class ChangeDateDatatypeSchedules < ActiveRecord::Migration
  def up
    execute "ALTER TABLE schedules DROP COLUMN date;"
    add_column :schedules, :date, :datetime
  end

  def down
  end
end
