class AddIsCommentsAutoCollapsedToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :is_comments_auto_collapsed, :boolean, default: true
  end
end
