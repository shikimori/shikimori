class CreateSimilarMangas < ActiveRecord::Migration
  def self.up
    create_table :similar_mangas do |t|
      t.integer :src_id
      t.integer :dst_id

      t.timestamps
    end
  end

  def self.down
    drop_table :similar_mangas
  end
end
