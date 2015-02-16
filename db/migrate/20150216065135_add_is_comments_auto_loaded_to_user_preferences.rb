class AddIsCommentsAutoLoadedToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :is_comments_auto_loaded, :boolean, default: true
  end
end
