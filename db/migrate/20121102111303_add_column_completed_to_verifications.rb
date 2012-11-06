class AddColumnCompletedToVerifications < ActiveRecord::Migration
  def change
    add_column :verfications, :completed, :boolean, :default => false
  end
end
