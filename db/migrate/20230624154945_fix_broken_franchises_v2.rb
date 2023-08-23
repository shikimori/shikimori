class FixBrokenFranchisesV2 < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[love_live tensei_shitara_slime_datta_ken])
    )
  end
end
