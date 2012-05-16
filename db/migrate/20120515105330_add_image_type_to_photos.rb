class AddImageTypeToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :image_type, :string
  end
end
