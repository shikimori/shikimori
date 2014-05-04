class AddIdToCommentViews < ActiveRecord::Migration
  def change
    add_column :comment_views, :id, :primary_key
  end
end
