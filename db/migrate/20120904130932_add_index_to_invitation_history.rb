class AddIndexToInvitationHistory < ActiveRecord::Migration
  def change
    add_index "invitation_histories", ["user_id"], :name => "index_invitation_histories_user_id"
  end
end
