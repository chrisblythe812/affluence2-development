class AddInvitationSourceToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :invitation_source, :string
  end
end
