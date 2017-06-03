class SwapSynonymsColumnsInAniemsAndMangas < ActiveRecord::Migration[5.0]
  def change
    rename_column :animes, :synonyms, :synonyms_old
    rename_column :animes, :synonyms_new, :synonyms

    rename_column :mangas, :synonyms, :synonyms_old
    rename_column :mangas, :synonyms_new, :synonyms
  end
end
