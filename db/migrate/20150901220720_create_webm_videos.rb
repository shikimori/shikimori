class CreateWebmVideos < ActiveRecord::Migration
  def change
    create_table :webm_videos do |t|
      t.string :url, limit: 1024, null: false
      t.string :state, null: false

      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at

      t.timestamps null: false
    end
    add_index :webm_videos, :url, unique: true
  end
end
