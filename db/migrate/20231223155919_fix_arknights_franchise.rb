class FixArknightsFranchise < ActiveRecord::Migration[7.0]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[arknights])
  end
end
