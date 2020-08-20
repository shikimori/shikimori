class AddStateIndexToAnimeVideos < ActiveRecord::Migration[5.2]
  def change
    add_index :anime_videos, %i(anime_id state)
  end
end
