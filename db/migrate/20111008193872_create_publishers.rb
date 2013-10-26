class CreatePublishers < ActiveRecord::Migration
  def self.up
    create_table :publishers do |t|
      t.string :name
      t.timestamps
    end
    create_table :mangas_publishers, :id => false do |t|
      t.integer :manga_id
      t.integer :publisher_id
    end
  end

  def self.down
    drop_table :publishers
    drop_table :mangas_publishers
  end
end
