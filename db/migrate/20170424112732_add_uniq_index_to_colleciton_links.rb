class AddUniqIndexToCollecitonLinks < ActiveRecord::Migration[5.0]
  def change
    add_index :collection_links, [:collection_id, :linked_id, :linked_type],
      unique: true,
      name: :uniq_collections_linked_links
  end
end
