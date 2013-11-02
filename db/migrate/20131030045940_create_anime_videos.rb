class CreateAnimeVideos < ActiveRecord::Migration
  def change
    create_table :anime_videos do |t|
      t.references :anime
      t.string :url,       :limit => 1000
      t.string :source,    :limit => 1000
      t.integer :episode
      t.string :kind
      t.string :language
      t.references :anime_video_author

      t.timestamps
    end
    add_index :anime_videos, :anime_id
    add_index :anime_videos, :anime_video_author_id
  end
end
