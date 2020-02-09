class AddIndexToExternalLinksChecksum < ActiveRecord::Migration[5.2]
  def up
    ExternalLink.where(checksum: nil).find_each { |v| v.send :compute_checksum; v.save! }

    change_column :external_links, :checksum, :string, null: false
    add_index :external_links, %i[checksum], unique: true
    remove_index :external_links, name: :external_links_url_entry_id_entry_type_source_uniq_index
  end

  def down
    change_column :external_links, :checksum, :string, null: true
    remove_index :external_links, %i[checksum], unique: true
    add_index :external_links, %i[url entry_id entry_type source],
      name: :external_links_url_entry_id_entry_type_source_uniq_index,
      unique: true
  end
end
