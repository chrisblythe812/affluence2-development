class AddPlanPermalinkToUser < ActiveRecord::Migration
  def change
    add_column :users, :plan, :string
    add_column :users, :permalink, :string
  end
end
