class CreateVerfications < ActiveRecord::Migration
  def change
    create_table :verfications do |t|
      t.references :user
      t.string :answer1
      t.string :answer2
      t.string :answer3
      t.string :status, :default => 'submited'
      t.timestamps
    end
  end
end
