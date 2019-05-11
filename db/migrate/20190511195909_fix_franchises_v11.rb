class FixFranchisesV11 < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[ys])
  end
end
