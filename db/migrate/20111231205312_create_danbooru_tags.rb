class CreateDanbooruTags < ActiveRecord::Migration
  def self.up
    create_table :danbooru_tags do |t|
      t.string :name
      t.integer :kind

      t.timestamps
    end
    add_index :danbooru_tags, [:name, :kind]
  end

  def self.down
    drop_table :danbooru_tags
  end
end
