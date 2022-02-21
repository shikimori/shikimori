class AddRatingsToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :score_2, :decimal, default: 0.0, null: false
    # add_column :animes, :score_3, :decimal, default: 0.0, null: false
    # add_column :animes, :score_4, :decimal, default: 0.0, null: false
    # add_column :animes, :score_5, :decimal, default: 0.0, null: false

    add_column :mangas, :score_2, :decimal, default: 0.0, null: false
    # add_column :mangas, :score_3, :decimal, default: 0.0, null: false
    # add_column :mangas, :score_4, :decimal, default: 0.0, null: false
    # add_column :mangas, :score_5, :decimal, default: 0.0, null: false
  end
end
