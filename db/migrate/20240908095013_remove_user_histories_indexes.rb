class RemoveUserHistoriesIndexes < ActiveRecord::Migration[7.1]
  def change
    remove_index :user_histories, %w[updated_at],
      name: "index_user_histories_on_updated_at"

    remove_index :user_histories, %w[user_id],
      name: "index_user_histories_on_user_id"
  end
end
