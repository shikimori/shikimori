class AddForumsToUserPreferences < ActiveRecord::Migration
  def change
    add_column(
      :user_preferences,
      :forums,
      :text,
      null: false,
      array: true,
      default: %w(
        animanga
        news
        vn
        games
        site
        offtopic
      )
    )
  end
end
