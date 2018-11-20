class RenameFranchiseAchievements < ActiveRecord::Migration[5.2]
  def up
    Achievement.where(neko_id: 'saiyuuki').update_all neko_id: 'saiyuki'
  end

  def down
    Achievement.where(neko_id: 'saiyuki').update_all neko_id: 'saiyuuki'
  end
end
