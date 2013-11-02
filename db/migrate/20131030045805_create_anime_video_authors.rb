class CreateAnimeVideoAuthors < ActiveRecord::Migration
  def change
    create_table :anime_video_authors do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :anime_video_authors_name, [:name], :unique => true
  end
end
