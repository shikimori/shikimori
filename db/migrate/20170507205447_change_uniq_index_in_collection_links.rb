class ChangeUniqIndexInCollectionLinks < ActiveRecord::Migration[5.0]
  def up
    remove_index :collection_links, name: :uniq_collections_linked_links
    add_index :collection_links, [:collection_id, :linked_id, :group],
      unique: true,
      name: :uniq_collections_linked_links
  end

  def down
    remove_index :collection_links, name: :uniq_collections_linked_links
    add_index :collection_links, [:collection_id, :linked_id, :linked_type],
      unique: true,
      name: :uniq_collections_linked_links
  end
end
