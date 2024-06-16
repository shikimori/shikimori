class RemoveMysteryAndPoliceAchievements < ActiveRecord::Migration[7.0]
  def up
    Achievement.where(neko_id: %[mystery police]).delete_all
  end

  def down
    Achievement.where(neko_id: %[detektiv]).delete_all
  end
end
