class CreateAnimeVideos < ActiveRecord::Migration
  def change
    create_table :anime_videos do |t|
      t.references :anime
      t.string :url
      t.integer :episode
      t.string :kind
      t.references :anime_video_author

      t.timestamps
    end
    add_index :anime_videos, :anime_id
    add_index :anime_videos, :anime_video_author_id
  end
end
