class AddStateIndexToAnimeVideos < ActiveRecord::Migration
  def change
    add_index :anime_videos, %i(anime_id state)
  end
end
