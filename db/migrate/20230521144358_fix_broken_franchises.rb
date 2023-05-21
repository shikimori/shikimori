class FixBrokenFranchises < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Manga.where(franchise: %w[young_shima_kousaku])
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[anisama daisuki msonic eagle_talon])
  end
end
