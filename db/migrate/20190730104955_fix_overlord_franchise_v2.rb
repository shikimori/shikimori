class FixOverlordFranchiseV2 < ActiveRecord::Migration[5.2]
  def change
    ids = Anime.where(franchise: 'overlord').pluck :id
    Anime.where(id: ids).update_all franchise: nil
    Animes::UpdateFranchises.new.call Anime.where(id: ids)
  end
end
