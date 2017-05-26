class RemoveWorldArtFieldsFromAnimes < ActiveRecord::Migration[5.0]
  def change
    remove_column :animes, :world_art_id, :integer, default: 0
    remove_column :animes, :world_art_synonyms, :text
  end
end
