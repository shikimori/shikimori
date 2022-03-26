class UpdateAllanimeStatHistoriesScore2ToNull < ActiveRecord::Migration[5.2]
  def up
    AnimeStatHistory.update(score_2: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
