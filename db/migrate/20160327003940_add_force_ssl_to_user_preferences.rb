class AddForceSslToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :force_ssl, :boolean, default: false, null: false
  end
end
