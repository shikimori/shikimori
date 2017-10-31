class AddSeasonToAnimes < ActiveRecord::Migration[5.1]
  def change
    add_column :animes, :season, :string
  end
end
