class AddProfileIdToPhotoStream < ActiveRecord::Migration
  def change
    add_column :photo_streams, :profile_id, :integer
  end
end
