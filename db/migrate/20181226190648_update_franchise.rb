class UpdateFranchise < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[3_gatsu_no_lion])
  end
end
