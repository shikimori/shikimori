class FixUmiseaFranchise < ActiveRecord::Migration[7.1]
  def up
    Animes::UpdateFranchises.new.call Anime.where(franchise: :umisea)
  end
end
