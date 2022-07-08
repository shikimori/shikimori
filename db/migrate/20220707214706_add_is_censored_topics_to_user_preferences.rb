class AddIsCensoredTopicsToUserPreferences < ActiveRecord::Migration[6.1]
  def change
    add_column :user_preferences, :is_view_censored, :boolean, null: false, default: false
  end
end
