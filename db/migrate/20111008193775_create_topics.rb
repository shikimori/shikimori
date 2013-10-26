class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :subject
      t.string :url
      t.integer :user_id
      t.integer :section_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
