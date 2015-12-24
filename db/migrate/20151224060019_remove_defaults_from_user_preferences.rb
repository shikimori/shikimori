class RemoveDefaultsFromUserPreferences < ActiveRecord::Migration
  def change
    change_column_default :user_preferences, :forums, []
  end
end
