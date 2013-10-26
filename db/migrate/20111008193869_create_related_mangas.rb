class CreateRelatedMangas < ActiveRecord::Migration
  def self.up
    create_table :related_mangas do |t|
      t.integer :source_id
      t.integer :anime_id
      t.integer :manga_id
      t.string :relation

      t.timestamps
    end
  end

  def self.down
    drop_table :related_mangas
  end
end
