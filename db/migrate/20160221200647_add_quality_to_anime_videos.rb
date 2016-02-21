class AddQualityToAnimeVideos < ActiveRecord::Migration
  def change
    add_column :anime_videos, :quality, :string, default: 'unknown'
  end
end
