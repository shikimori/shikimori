class SetScore2ToZeroForAnonses < ActiveRecord::Migration[5.2]
  def up
    Anime.where(status: 'anons').update(score_2: 0)
    Manga.where(status: 'anons').update(score_2: 0)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
