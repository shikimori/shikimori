class FixMahouShoujoLyricalNanohaFranchise < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: %w[fate fate_apocrypha])
  end
end
