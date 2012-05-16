class AddColumnStatusToEvents < ActiveRecord::Migration
  def change
    add_column :events, :status, :boolean, :default => false
  end
end
