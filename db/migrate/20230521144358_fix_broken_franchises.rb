class FixBrokenFranchises < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Manga.where(franchise: %w[young_shima_kousaku])

    ids = Anime.where franchise: %w[
      anisama daisuki msonic eagle_talon monster_strike
    ]
    Anime.where(id: ids).update_all franchise: nil
    Animes::UpdateFranchises.new.call Anime.where(id: ids)
  end
end
