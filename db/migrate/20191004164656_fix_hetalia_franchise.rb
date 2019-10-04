class FixHetaliaFranchise < ActiveRecord::Migration[5.2]
  IDS = [
    9865, 7337, 28607, 15195, 10497, 5060, 5372, 20975, 31158, 31997, 21075, 574, 17273,
    929, 1657, 8479
  ]

  def change
    Anime.where(id: IDS).update_all franchise: nil
    Animes::UpdateFranchises.new.call Anime.where(id: IDS)
  end
end
