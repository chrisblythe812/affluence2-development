class CreatePromotionsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :promotions_users, :id => false  do |t|
      t.integer :promotion_id
      t.integer :user_id
    end
  end
end