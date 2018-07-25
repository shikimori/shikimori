class FixFranchisesV6 < ActiveRecord::Migration[5.1]
  def change
    Achievement
      .where(neko_id: 'casshern')
      .update_all neko_id: 'gatchaman'
    Animes::UpdateFranchises.new.call(Anime.where(franchise: %w[gall_force]))
  end
end
