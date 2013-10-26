class RenameCommentThreadsCountOnEntries < ActiveRecord::Migration
  def up
    rename_column :entries, :comment_threads_count, :comments_count
  end

  def down
    rename_column :entries, :comments_count, :comment_threads_count
  end
end
