class CreatePayablePromotions < ActiveRecord::Migration
  def change
    create_table :payable_promotions do |t|
      t.integer :user_id
      t.integer :promotion_id
      t.string :name
      t.string :email
      t.integer :phone
      t.integer :total_tickets
      t.integer :total_amount
      t.integer :price_per_ticket
      t.string :discount
      t.timestamps
    end


    add_index :payable_promotions, :user_id, :name => :index_payable_promotions_on_user_id
    add_index :payable_promotions, :promotion_id, :name => :index_payable_promotions_on_promotion_id

  end
end
