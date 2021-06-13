class RemoveUnneededIndexesV3 < ActiveRecord::Migration[5.2]
  def change
    remove_index :collection_roles,
      name: 'index_collection_roles_on_user_id',
      column: :user_id
    remove_index :user_rate_logs,
      name: 'index_user_rate_logs_on_user_id',
      column: :user_id
  end
end
