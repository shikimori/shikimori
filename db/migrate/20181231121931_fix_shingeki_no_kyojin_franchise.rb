class FixShingekiNoKyojinFranchise < ActiveRecord::Migration[5.2]
  def change
    ids = Anime.where(franchise: 'shingeki_no_kyojin').pluck :id

    Anime.where(id: ids).update_all franchise: nil

    Animes::UpdateFranchises.new.call Anime.where(id: ids)
  end
end
