class RemoveSeinenAndAcitonAchievements < ActiveRecord::Migration[5.2]
  def change
    Achievement.where(neko_id: %i[seinen action]).delete_all
  end
end
