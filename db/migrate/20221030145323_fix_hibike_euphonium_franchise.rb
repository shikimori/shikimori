class FixHibikeEuphoniumFranchise < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[hibike_euphonium])
  end
end
