class CreateConcierges < ActiveRecord::Migration
  def change
    create_table :concierges do |t|
      t.string :title
      t.text :description
      t.string :number
      t.timestamps
    end
  end
end
