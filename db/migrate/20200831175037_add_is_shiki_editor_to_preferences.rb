class AddIsShikiEditorToPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :user_preferences, :is_shiki_editor, :boolean,
      default: false,
      null: false
  end
end
