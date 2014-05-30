class CreateMangaPages < ActiveRecord::Migration
  def change
    create_table :manga_pages do |t|
      t.string :url
      t.integer :number
      t.references :manga_chapter, index: true

      t.timestamps
    end
  end
end
