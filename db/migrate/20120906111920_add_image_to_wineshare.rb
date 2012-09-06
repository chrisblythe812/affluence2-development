class AddImageToWineshare < ActiveRecord::Migration
  def change
    add_column :wine_shares, :media_type, :string
    add_column :wine_shares, :media_url, :string
  end
end
