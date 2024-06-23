class ChangeIsShikiEditorInUserPreferencesToBeTrueByDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_preferences, :is_shiki_editor, from: false, to: true
  end
end
