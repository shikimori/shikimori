class RemoveUnneededIndexesV4 < ActiveRecord::Migration[5.2]
  def change
    remove_index :oauth_access_tokens, name: "index_oauth_access_tokens_on_resource_owner_id"
  end
end
