class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.references :promotionable, :polymorphic => true
      t.timestamps
    end
  end
    #add_index "promotions", ["promotionable_id", "promotionable_type"], :name => "promotion_event"
end
