class FixFranchisesV5 < ActiveRecord::Migration[5.1]
  def change
    Animes::UpdateFranchises.new.call(
      Anime.where(franchise: %w[soniani locker_room casshern])
    )
    Achievement
      .where(neko_id: 'locker_room')
      .update_all neko_id: 'inazuma_eleven'
  end
end
