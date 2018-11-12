class AddAchievementsIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :achievements, %i[neko_id level]
  end
end
