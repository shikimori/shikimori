class AddGenreV2IdsToAnimesAndMangas < ActiveRecord::Migration[6.1]
  def change
    add_column :animes, :genre_v2_ids, :integer,
      default: [],
      null: false,
      array: true
    add_column :mangas, :genre_v2_ids, :integer,
      default: [],
      null: false,
      array: true
  end
end
