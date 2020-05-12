class FixMazinkaiserFranchise < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[mazinkaiser])
    )
  end
end
