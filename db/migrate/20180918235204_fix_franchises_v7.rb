class FixFranchisesV7 < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call(Anime.where(franchise: %w[detective_conan]))
  end
end
