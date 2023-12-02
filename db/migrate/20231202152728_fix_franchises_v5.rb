class FixFranchisesV5 < ActiveRecord::Migration[7.0]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[hello_kitty])
  end
end
