class CreateMangaChapters < ActiveRecord::Migration
  def change
    create_table :manga_chapters do |t|
      t.string :name
      t.string :url
      t.references :manga, index: true

      t.timestamps
    end
  end
end
