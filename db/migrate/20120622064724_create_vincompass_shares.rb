class CreateVincompassShares < ActiveRecord::Migration
  def change
    create_table :vincompass_shares do |t|
      t.string :title
      t.timestamps
    end
  end
end
