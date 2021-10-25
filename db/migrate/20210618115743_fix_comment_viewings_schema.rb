class FixCommentViewingsSchema < ActiveRecord::Migration[5.2]
  def up
    execute %q[
      delete from comment_viewings where user_id in (
        select distinct(comment_viewings.user_id)
          from comment_viewings
          left join users
            on users.id = comment_viewings.user_id
          where users.id is null
      )
    ]

    change_column :comment_viewings, :user_id, :integer, null: false
    change_column :comment_viewings, :viewed_id, :integer, null: false

    add_foreign_key :comment_viewings, :users
  end

  def down
    remove_foreign_key :comment_viewings, :users
  end
end
