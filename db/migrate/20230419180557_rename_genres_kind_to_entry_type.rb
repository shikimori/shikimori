class RenameGenresKindToEntryType < ActiveRecord::Migration[6.1]
  def change
    rename_column :genres, :kind, :entry_type
  end
end
