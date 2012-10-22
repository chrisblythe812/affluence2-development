class AddTitleConciergeRequest < ActiveRecord::Migration
  def up
    add_column :concierge_requests, :title, :string
  end

  def down
    remove_column :concierge_requests, :title, :string
  end
end
