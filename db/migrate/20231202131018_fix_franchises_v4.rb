class FixFranchisesV4 < ActiveRecord::Migration[7.0]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[burn_the_witch bleach])
  end
end
