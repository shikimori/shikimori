class AddCachedRatesCountToAnimesAndMangas < ActiveRecord::Migration[5.1]
  def change
    add_column :animes, :cached_rates_count, :integer, null: false, default: 0
    add_column :mangas, :cached_rates_count, :integer, null: false, default: 0
  end
end
