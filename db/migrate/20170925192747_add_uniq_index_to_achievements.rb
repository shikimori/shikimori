class AddUniqIndexToAchievements < ActiveRecord::Migration[5.1]
  def change
    add_index :achievements, %i[user_id neko_id level], unique: true
  end
end
