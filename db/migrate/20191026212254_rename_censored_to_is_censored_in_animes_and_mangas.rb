class RenameCensoredToIsCensoredInAnimesAndMangas < ActiveRecord::Migration[5.2]
  def change
    rename_column :animes, :censored, :is_censored
    rename_column :mangas, :censored, :is_censored
  end
end
