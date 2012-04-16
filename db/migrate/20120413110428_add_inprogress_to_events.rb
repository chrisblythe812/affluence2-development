class AddInprogressToEvents < ActiveRecord::Migration
  def change
    add_column :events, :inprogress, :integer, :default => 0
    add_column :events, :permalink, :string
  end
end
