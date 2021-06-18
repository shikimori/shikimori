class FixCommentViewingsSchema < ActiveRecord::Migration[5.2]
  def change
    change_column :comment_viewings, :user_id, :integer, null: false
    change_column :comment_viewings, :viewed_id, :integer, null: false

    add_foreign_key :comment_viewings, :users
  end
end
