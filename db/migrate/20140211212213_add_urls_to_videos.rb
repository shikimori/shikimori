class AddUrlsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :image_url, :string, limit: 1024
    add_column :videos, :player_url, :string, limit: 1024
  end
end
