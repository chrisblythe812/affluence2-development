class AddColumnsToPhotoStream < ActiveRecord::Migration
  def change
    add_column :photo_streams, :title, :string

    add_column :photo_streams, :description, :text

  end
end
