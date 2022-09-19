class FixNanatsuNoTaizaiFranchise < ActiveRecord::Migration[6.1]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: ['nanatsu_no_taizai'])
  end
end
