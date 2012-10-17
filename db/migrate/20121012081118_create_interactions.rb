class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.references :concierge_request
      t.references :interactable, :polymorphic => true
      t.timestamps
    end
  end
end
