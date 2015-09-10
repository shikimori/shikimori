class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :anime_video_reports, [:user_id, :state]
    add_index :versions, [:user_id, :state]
    add_index :user_tokens, :user_id
    add_index :images, [:owner_type, :owner_id]
    add_index :related_animes, :source_id
    add_index :related_mangas, :source_id
    add_index :danbooru_tags, :name
  end
end
