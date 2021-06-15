class FixTalesOfFranchise < ActiveRecord::Migration[5.2]
  def change
    Anime.where(id: [46089, 42832, 38361, 391]).each do |anime|
      anime.update franchise: 'tales_of'
    end
  end
end
