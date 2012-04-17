class AddDefaultRoleToUser < ActiveRecord::Migration
  def change
    change_column :users, :role, :string, :default => 'member'
  end
end
  