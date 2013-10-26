class CreateScreenshots < ActiveRecord::Migration
  def self.up
    create_table :screenshots do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.integer :anime_id
      t.string :url

      t.timestamps
    end

    add_index :screenshots, :anime_id
    add_index :screenshots, [:anime_id, :url], :unique => true
  end

  def self.down
    drop_table :screenshots
  end
end
