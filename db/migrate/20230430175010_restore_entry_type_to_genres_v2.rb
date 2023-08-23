class RestoreEntryTypeToGenresV2 < ActiveRecord::Migration[6.1]
  def change
    add_column :genre_v2s, :entry_type, :string, null: false, default: 'Anime'
    change_column_default :genre_v2s, :entry_type, from: 'Anime', to: nil
  end
end
