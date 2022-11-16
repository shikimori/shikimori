class FixAtomFranchise < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[atom])
  end
end
