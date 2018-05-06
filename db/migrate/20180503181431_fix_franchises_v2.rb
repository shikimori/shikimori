class FixFranchisesV2 < ActiveRecord::Migration[5.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[perman])
    )
  end
end
