class AddRankedRandomToMangas < ActiveRecord::Migration[6.1]
  def change
    add_column :mangas, :ranked_random, :integer
  end
end
