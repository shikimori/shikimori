class AddSynonymsNewToAnimesAndMangas < ActiveRecord::Migration[5.0]
  def change
    add_column :animes, :synonyms_new, :text, default: [], null: false, array: true
    add_column :mangas, :synonyms_new, :text, default: [], null: false, array: true
  end
end
