class CreateAnimeVideoAuthors < ActiveRecord::Migration
  def change
    create_table :anime_video_authors do |t|
      t.string :name

      t.timestamps
    end
  end
end
