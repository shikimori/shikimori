class AddLicensorsToAnimeAndMangas < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :licensors, :string,
      default: [],
      null: false,
      array: true
    add_column :mangas, :licensors, :string,
      default: [],
      null: false,
      array: true
  end
end
