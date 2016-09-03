class RenameEntryAndCommentViews < ActiveRecord::Migration
  def change
    rename_table :entry_views, :topic_viewings
    rename_table :comment_views, :comment_viewings

    rename_column :topic_viewings, :entry_id, :viewed_id
    rename_column :comment_viewings, :comment_id, :viewed_id
  end
end
