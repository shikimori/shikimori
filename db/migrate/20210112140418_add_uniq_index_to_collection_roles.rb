class AddUniqIndexToCollectionRoles < ActiveRecord::Migration[5.2]
  def change
    add_index :collection_roles, %i[user_id collection_id], unique: true
  end
end
