class CreateInvitationHistories < ActiveRecord::Migration  
  def change
    create_table :invitation_histories do |t|
      t.string :email
      t.integer :user_id
      t.integer :status, :default => 0

      t.timestamps
    end
  end
end
