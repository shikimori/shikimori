class RemoveStylesFieldsFromPreferences < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_preferences, :page_border, :boolean, default: false
    remove_column :user_preferences, :page_background, :string, default: ''
    remove_column :user_preferences, :body_background, :string, default: ''
  end
end
