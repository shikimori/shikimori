class AddAuthorizedImportedAtToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :authorized_imported_at, :datetime
  end
end
