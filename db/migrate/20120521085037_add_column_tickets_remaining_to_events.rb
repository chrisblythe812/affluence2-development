class AddColumnTicketsRemainingToEvents < ActiveRecord::Migration
  def change
    add_column :events, :tickets_remaining, :integer
  end
end
