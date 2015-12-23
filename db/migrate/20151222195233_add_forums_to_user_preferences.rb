class AddForumsToUserPreferences < ActiveRecord::Migration
  def change
    add_column(
      :user_preferences,
      :forums,
      :text,
      null: false,
      array: true,
      default: %w(1 news 17 16 4 8)
    )
  end
end
