class AddImportedAtToExternalLinks < ActiveRecord::Migration
  def change
    add_column :external_links, :imported_at, :datetime
  end
end
