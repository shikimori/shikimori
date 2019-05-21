class RemoveOreNoImoutoAchievement < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: 'ore_no_imouto').delete_all
  end
end
