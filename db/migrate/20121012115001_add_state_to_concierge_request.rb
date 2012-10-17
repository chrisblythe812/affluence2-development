class AddStateToConciergeRequest < ActiveRecord::Migration
  def change
    add_column :concierge_requests, :completion_date, :date
    add_column :concierge_requests, :workflow_state, :string
  end
end
