class FixFranchisesV8 < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        Anime.where(franchise: :minipato).update_all franchise: :mobile_police_patlabor
        Animes::UpdateFranchises.new.call Anime.all
      end
      dir.down do
        Anime.where(franchise: :mobile_police_patlabor).update_all franchise: :minipato
      end
    end
  end
end

