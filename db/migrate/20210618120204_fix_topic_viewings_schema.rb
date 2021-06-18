class FixTopicViewingsSchema < ActiveRecord::Migration[5.2]
  def change
    change_column :topic_viewings, :user_id, :integer, null: false
    change_column :topic_viewings, :viewed_id, :integer, null: false

    add_foreign_key :topic_viewings, :users
  end
end
