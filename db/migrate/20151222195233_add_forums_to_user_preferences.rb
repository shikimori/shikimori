class AddForumsToUserPreferences < ActiveRecord::Migration
  def change
    add_column(
      :user_preferences,
      :forums,
      :text,
      null: false,
      array: true,
      default: Forums::List.new.map(&:id)
    )
  end
end
