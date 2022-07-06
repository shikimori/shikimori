class AddRankedRandomToAnimes < ActiveRecord::Migration[6.1]
  def change
    add_column :animes, :ranked_random, :integer
  end
end
