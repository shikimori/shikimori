class RemoveDefaultValueFromAnimeStatHistoriesScore2 < ActiveRecord::Migration[5.2]
  def up
    change_column_default(:anime_stat_histories, :score_2, nil)
  end

  def down
    change_column_default(:anime_stat_histories, :score_2, 0.0)
  end
end
