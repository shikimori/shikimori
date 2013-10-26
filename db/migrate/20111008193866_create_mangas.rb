class CreateMangas < ActiveRecord::Migration
  def self.up
    create_table :mangas do |t|
      t.string :name
      t.text :description, :description_mal

      t.string :kind

      t.integer :volumes, :null => false, :default => 0
      t.integer :volumes_aired, :null => false, :default => 0
      t.integer :chapters, :null => false, :default => 0
      t.integer :chapters_aired, :null => false, :default => 0

      t.string :status

      t.text :english, :japanese, :synonyms
      t.string :russian

      t.float :score
      t.integer :ranked, :popularity
      t.string :rating

      t.date :published_at
      t.date :released_at
      t.date :imported_at

      t.string :mal_scores

      t.integer  :editor_id

      t.integer :page_views_counter, :default => 0

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.boolean :censored, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :mangas
  end
end
