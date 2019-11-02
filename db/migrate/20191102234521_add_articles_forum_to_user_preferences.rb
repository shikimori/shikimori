class AddArticlesForumToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    UserPreferences
      .connection
      .execute(
        <<~SQL
          update user_preferences
            set
              forums = array_append(forums, '21')
        SQL
      ).to_a
  end
end
