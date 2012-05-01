class AddColumnsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :sale_ends_at, :date

    add_column :events, :tickets, :integer

  end
end
