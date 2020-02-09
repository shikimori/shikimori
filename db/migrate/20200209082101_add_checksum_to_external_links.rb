class AddChecksumToExternalLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :external_links, :checksum, :string
  end
end
