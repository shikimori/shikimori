class AddRankedShikiToMangas < ActiveRecord::Migration[6.1]
  def change
    add_column :mangas, :ranked_shiki, :integer
  end
end
