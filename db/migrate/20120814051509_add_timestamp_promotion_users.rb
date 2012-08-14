class AddTimestampPromotionUsers < ActiveRecord::Migration
  def up
    add_column(:promotions_users, :created_at, :datetime)
  end


end
