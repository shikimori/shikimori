class AddStylesFieldsToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :page_background, :string
    add_column :user_preferences, :page_border, :boolean, default: false
    add_column :user_preferences, :body_background, :string
    add_column :user_preferences, :show_smileys, :boolean, default: true
    add_column :user_preferences, :show_social_buttons, :boolean, default: true
  end
end
