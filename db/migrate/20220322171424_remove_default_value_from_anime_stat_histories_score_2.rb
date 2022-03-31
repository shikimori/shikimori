class RemoveDefaultValueFromAnimeStatHistoriesScore2 < ActiveRecord::Migration[5.2]
  def up
    change_column_default :anime_stat_histories, :score_2, from: 0.0, to: nil
    change_column :anime_stat_histories, :score_2, :decimal, null: true
  end

  def down
    change_column_default :anime_stat_histories, :score_2, from: nil, to: 0.0
    change_column :anime_stat_histories, :score_2, :decimal, null: false
  end
end
