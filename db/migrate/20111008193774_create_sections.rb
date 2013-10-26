class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.integer :position
      t.string :name
      t.string :description
      t.string :url

      t.integer :forum_id

      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
