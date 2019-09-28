class AddExternalLinksUniqueIndex < ActiveRecord::Migration[5.2]
  def change
    cleanup do
      ExternalLink.group('url, entry_id, entry_type, source').having('count(*) > 1').select('max(id) as id, count(*) as count')
    end

    add_index :external_links,
      %i[url entry_id entry_type source],
      unique: true,
      name: :external_links_url_entry_id_entry_type_source_uniq_index
  end

private

  def cleanup
    while yield.any?
      ExternalLink.where(id: yield.map(&:id)).destroy_all
    end
  end
end
