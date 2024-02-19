class RestoreEntryTypeToGenresV2 < ActiveRecord::Migration[6.1]
  def change
    add_column :genres_v2, :entry_type, :string, null: false, default: 'Anime'
    change_column_default :genres_v2, :entry_type, from: 'Anime', to: nil
  end
end
