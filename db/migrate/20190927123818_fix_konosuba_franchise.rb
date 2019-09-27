class FixKonosubaFranchise < ActiveRecord::Migration[5.2]
  def change
    Animes::UpdateFranchises.new.call Anime.where(franchise: ['konosuba'])
  end
end
