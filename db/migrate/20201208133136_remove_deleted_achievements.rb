class RemoveDeletedAchievements < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: 'nurarihyon_no_mago').delete_all
  end
end
