class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :status, :string
    add_column :users, :role, :string
  end
end
