class CreatePhotoStreams < ActiveRecord::Migration
  def change
    create_table :photo_streams do |t|

      t.timestamps
    end
  end
end
