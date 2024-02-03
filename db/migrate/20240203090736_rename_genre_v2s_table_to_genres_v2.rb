class RenameGenreV2sTableToGenresV2 < ActiveRecord::Migration[7.0]
  def change
    rename_table :genre_v2s, :genres_v2
  end
end
