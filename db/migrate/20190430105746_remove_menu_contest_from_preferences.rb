class RemoveMenuContestFromPreferences < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_preferences, :menu_contest, :boolean, null: false, default: true
  end
end
