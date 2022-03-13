class AddRatingsToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :score_2, :decimal, default: 0.0, null: false
    add_column :mangas, :score_2, :decimal, default: 0.0, null: false
  end
end
