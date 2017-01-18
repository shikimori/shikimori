class AddAuthorizedImportedAtToAnimes < ActiveRecord::Migration
  def change
    add_column :animes, :authorized_imported_at, :datetime
  end
end
