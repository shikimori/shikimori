class RemoveDeletedAchievementsV2 < ActiveRecord::Migration[5.1]
  def change
    Achievement.where(neko_id: %w[katekyo_hitman_reborn]).destroy_all
  end
end
