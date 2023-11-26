class FixFranchisesV3 < ActiveRecord::Migration[7.0]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[yuki_no_joou])
  end
end
