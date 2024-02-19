class RenameGenreV2sTableToGenresV2 < ActiveRecord::Migration[7.0]
  def up
    return unless ActiveRecord::Base.connection.data_source_exists? 'genre_v2s'
    rename_table :genre_v2s, :genres_v2
  end
end
