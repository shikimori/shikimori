class FixFranchisesV3 < ActiveRecord::Migration[5.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[utopia])
    )
  end
end
