class FixTopicViewingsSchema < ActiveRecord::Migration[5.2]
  def up
    execute %q[
      delete from topic_viewings where user_id in (
        select distinct(topic_viewings.user_id)
          from topic_viewings
          left join users
            on users.id = topic_viewings.user_id
          where users.id is null
      )
    ]

    change_column :topic_viewings, :user_id, :integer, null: false
    change_column :topic_viewings, :viewed_id, :integer, null: false

    add_foreign_key :topic_viewings, :users
  end

  def down
    remove_foreign_key :topic_viewings, :users
  end
end
