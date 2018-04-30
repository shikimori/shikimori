class FixFranchises < ActiveRecord::Migration[5.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[new_game atom mahou_no_yousei_persia])
    )
    Achievement.delete_all
  end
end
