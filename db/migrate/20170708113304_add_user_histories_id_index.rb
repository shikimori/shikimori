class AddUserHistoriesIdIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :user_histories, %i[target_type user_id id]
  end
end
