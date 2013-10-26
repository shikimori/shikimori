class CreateCommentViews < ActiveRecord::Migration
  def self.up
    create_table :comment_views, :id => false do |t|
      t.integer :user_id
      t.integer :comment_id
    end
    add_index :comment_views, [:user_id, :comment_id]
  end

  def self.down
    drop_table :comment_views
  end
end
