class RemoveCritiquesCommentId < ActiveRecord::Migration[5.2]
  def change
    remove_column :critiques, :comment_id, :integer
  end
end
