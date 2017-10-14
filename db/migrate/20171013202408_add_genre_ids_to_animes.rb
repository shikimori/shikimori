class AddGenreIdsToAnimes < ActiveRecord::Migration[5.1]
  def change
    add_column :animes, :genre_ids, :integer,
      array: true,
      null: false,
      default: []
  end
end
