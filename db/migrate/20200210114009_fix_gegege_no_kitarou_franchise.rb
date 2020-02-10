class FixGegegeNoKitarouFranchise < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[gegege_no_kitarou])
    )
  end
end
