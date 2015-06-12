class AddBodyWidthToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :body_width, :string, null: false, default: 'x1200'
  end
end
