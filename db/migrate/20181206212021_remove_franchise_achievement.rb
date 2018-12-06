class RemoveFranchiseAchievement < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: %i[maison_ikkoku]).delete_all
  end
end
