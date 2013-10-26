class CreateTopicViews < ActiveRecord::Migration
  def self.up
    create_table :topic_views do |t|
      t.integer :topic_id
      t.integer :user_id
      t.integer :comment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_views
  end
end
