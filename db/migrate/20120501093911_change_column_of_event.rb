class ChangeColumnOfEvent < ActiveRecord::Migration
  def up
    change_column :events, :sale_ends_at, :date, :null => false
    change_column :events, :tickets, :integer, :null => false
  end

  def down
    change_column :events, :sale_ends_at, :date
    change_column :events, :tickets, :integer
  end
end
