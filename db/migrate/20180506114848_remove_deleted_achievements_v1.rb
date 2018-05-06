class RemoveDeletedAchievementsV1 < ActiveRecord::Migration[5.1]
  def change
    Achievement.where(neko_id: %w[evangelion seikai_no_senki]).destroy_all
  end
end
