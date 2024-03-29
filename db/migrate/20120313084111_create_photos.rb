class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.references :photoable, :polymorphic => true
      t.string :title
      t.text :description
      t.timestamps
    end
  end
end
