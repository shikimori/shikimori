class FixFranchisesV7 < ActiveRecord::Migration[7.0]
  def up
    Animes::UpdateFranchises.new.call(
      Anime.where(
        franchise: %w[
          planetarian kaginado umisea dragon_ball tian_yu wu_geng_ji
        ]
      )
    )
  end
end
