class RemoveTomoharuKatsumataAchievements < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: :tomoharu_katsumata).delete_all
  end
end
