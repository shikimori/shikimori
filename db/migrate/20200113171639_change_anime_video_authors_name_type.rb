class ChangeAnimeVideoAuthorsNameType < ActiveRecord::Migration[5.2]
  def up
    change_column :anime_video_authors, :name, :text
  end

  def down
    change_column :anime_video_authors, :name, :string
  end
end
