class AddIsFirstToAnimeVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :anime_videos, :is_first, :boolean, null: false, default: false
  end
end
