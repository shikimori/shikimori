class AddSuggestedIndexesV3 < ActiveRecord::Migration[5.2]
  def change
    commit_db_transaction
    add_index :oauth_access_tokens,
      [:resource_owner_id, :application_id],
      algorithm: :concurrently,
      name: :index_oauth_access_tokens_on_resource_owner_id_and_app_id
  end
end
