class AddIndexToCommentViews < ActiveRecord::Migration
  def self.up
    add_index :comment_views, :comment_id
  end

  def self.down
    remove_index :comment_views, :comment_id
  end
end
