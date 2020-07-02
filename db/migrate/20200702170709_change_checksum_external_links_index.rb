class ChangeChecksumExternalLinksIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :external_links, %w[checksum]
    add_index :external_links, %w[checksum],
      where: "url != '#{ExternalLink::NO_URL}'",
      unique: true
  end

  def down
    remove_index :external_links, %w[checksum]
    add_index :external_links, %w[checksum], unique: true
  end
end
