class AddDefaultPhotoStreamTitle < ActiveRecord::Migration
  def up
    change_column_default(:photo_streams, :title, 'Untitled Albumn')
  end

  def down
    change_column_default(:photo_streams, :title, nil)
  end
end
  