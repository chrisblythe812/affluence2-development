class ChangePhoneInPayablePromotions < ActiveRecord::Migration
  def up
   change_column  :payable_promotions, :phone, :string
  end

  def down
    change_column  :payable_promotions, :phone, :integer
  end
end
