class ChangeBodyBackgroundInUserPreferences < ActiveRecord::Migration
  def change
    change_column :user_preferences, :body_background, :string, limit: 512
  end
end
