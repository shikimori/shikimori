class RemoveMysteryAndPoliceAchievements < ActiveRecord::Migration[7.0]
  def up
    Achievement.where(neko_id: %i[mystery police]).delete_all
  end

  def down
    Achievement.where(neko_id: %i[detektiv]).delete_all
  end
end
