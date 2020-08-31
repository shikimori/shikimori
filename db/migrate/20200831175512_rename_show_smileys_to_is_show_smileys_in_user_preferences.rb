class RenameShowSmileysToIsShowSmileysInUserPreferences < ActiveRecord::Migration[5.2]
  def change
    rename_column :user_preferences, :show_smileys, :is_show_smileys
  end
end
