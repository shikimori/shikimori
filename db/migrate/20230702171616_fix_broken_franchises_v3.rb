class FixBrokenFranchisesV3 < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[die_now])
    )
  end
end
