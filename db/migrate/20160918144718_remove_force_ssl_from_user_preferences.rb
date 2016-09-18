class RemoveForceSslFromUserPreferences < ActiveRecord::Migration
  def change
    remove_column :user_preferences, :force_ssl, :boolean,
      default: false,
      null: false
  end
end
