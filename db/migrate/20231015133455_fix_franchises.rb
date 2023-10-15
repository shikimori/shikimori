class FixFranchises < ActiveRecord::Migration[7.0]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(
        franchise: %w[
          rent_a_girlfriend
          yakusoku_no_neverland
          fire_force
          temple
          choco_kyouju_no_oheya
          gamera
          ookami_kodomo_no_ame_to_yuki
          mirai
        ]
      )
    )
  end
end
