class FixFranchisesV7 < ActiveRecord::Migration[7.0]
  def up
    Animes::UpdateFranchises.new.call(
      Anime.where(
        franchise: %w[
          planetarian kaginado umisea tian_yu dragon_ball
        ]
      )
    )
  end
end
