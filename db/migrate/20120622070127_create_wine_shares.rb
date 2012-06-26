class CreateWineShares < ActiveRecord::Migration
  def change
    create_table :wine_shares do |t|
      t.string :name
      t.string :year
      t.string :region
      t.string :grape
      t.string :producer
      t.string :link
      t.string :comment
      t.integer :vincompass_share_id
      t.string :restaurant_name
      t.timestamps
    end
  end
end
