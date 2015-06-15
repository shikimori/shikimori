class ChangeAnimeVideoAuthorsIndex < ActiveRecord::Migration
  def change
    remove_index :anime_video_authors, [:name]
    add_index :anime_video_authors, [:name]
  end
end
