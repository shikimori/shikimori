class AddApplyUserStylesToPreferences < ActiveRecord::Migration[5.1]
  def change
    add_column :user_preferences, :apply_user_styles, :boolean, null: false, default: true
  end
end
