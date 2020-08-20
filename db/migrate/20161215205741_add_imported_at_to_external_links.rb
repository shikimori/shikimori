class AddImportedAtToExternalLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :external_links, :imported_at, :datetime
  end
end
