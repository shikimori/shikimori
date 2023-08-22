class FixRentAGirlfriendFranchise < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[rent_a_girlfriend])
  end
end
