class RemoveAchievement < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: :yoshikazu_yasuhiko).delete_all
  end
end
