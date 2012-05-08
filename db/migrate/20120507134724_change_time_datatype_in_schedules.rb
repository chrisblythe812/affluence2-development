class ChangeTimeDatatypeInSchedules < ActiveRecord::Migration
  def up
    execute "ALTER TABLE schedules DROP COLUMN time;"
    execute "ALTER TABLE schedules ADD COLUMN time time;"

  end

  def down

  end
end
