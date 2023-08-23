class RemoveEntryTypeFromGenresV2 < ActiveRecord::Migration[6.1]
  def change
    remove_column :genre_v2s, :entry_type, :string, null: false, default: 'Anime'
  end
end
