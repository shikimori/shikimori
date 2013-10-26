class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :name
      t.string :url
      t.references :uploader
      t.references :anime
      t.string :kind
      t.string :state

      t.timestamps
    end

    add_index :videos, :anime_id
    add_index :videos, :state
  end
end
