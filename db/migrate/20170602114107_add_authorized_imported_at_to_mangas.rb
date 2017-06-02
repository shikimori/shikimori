class AddAuthorizedImportedAtToMangas < ActiveRecord::Migration[5.0]
  def change
    add_column :mangas, :authorized_imported_at, :datetime
  end
end
