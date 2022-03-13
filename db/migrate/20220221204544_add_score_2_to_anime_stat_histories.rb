class AddScore2ToAnimeStatHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :anime_stat_histories, :score_2, :decimal, default: 0.0, null: false
  end
end
