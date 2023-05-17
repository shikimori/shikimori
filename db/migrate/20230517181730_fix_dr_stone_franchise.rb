class FixDrStoneFranchise < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[dr_stone])
  end
end
