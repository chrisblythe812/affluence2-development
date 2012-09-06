class AddTimestampPromotionUsers < ActiveRecord::Migration
  def up
    add_column :promotions_users, :created_at, :datetime
  end

  #def down
   # remove_column :promotions_users, :created_at, :datetime
  #end

end
