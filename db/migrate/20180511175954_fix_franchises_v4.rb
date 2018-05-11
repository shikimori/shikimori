class FixFranchisesV4 < ActiveRecord::Migration[5.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[dr_slump toaru_majutsu_no_index])
    )
  end
end
