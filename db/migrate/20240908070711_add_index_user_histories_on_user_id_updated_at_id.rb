class AddIndexUserHistoriesOnUserIdUpdatedAtId < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!  # This is required for concurrent index creation

  def change
    add_index :user_histories, [:user_id, :updated_at, :id],
      order: { updated_at: :desc, id: :desc },
      algorithm: :concurrently,
      name: 'index_user_histories_on_user_id_updated_at_id'
  end
end
