class FixShingekiNoKyojinFranchise < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: 'shingeki_no_kyojin')
  end
end
