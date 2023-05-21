class FixBrokenFranchises < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Manga.where(franchise: %w[young_shima_kousaku])
  end
end
