class CreateMangaChaptersAndPages < ActiveRecord::Migration
  def change
    create_table :manga_chapters do |t|
      t.string :name
      t.string :url
      t.references :manga, index: true

      t.timestamps
    end

    create_table :manga_pages do |t|
      t.string :url
      t.integer :number
      t.references :manga_chapter, index: true
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size

      t.timestamps
    end

  end
end
