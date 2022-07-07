class AddIsShowAgeToUserPreferences < ActiveRecord::Migration[6.1]
  def change
    add_column :user_preferences, :is_show_age, :boolean, null: false, default: true
  end
end
