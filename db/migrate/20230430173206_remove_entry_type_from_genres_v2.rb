class RemoveEntryTypeFromGenresV2 < ActiveRecord::Migration[6.1]
  def change
    remove_column :genres_v2, :entry_type, :string, null: false, default: 'Anime'
  end
end
