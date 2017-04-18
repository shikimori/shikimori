class AddTopicsForumToUsersForums < ActiveRecord::Migration[5.0]
  def up
    UserPreferences.connection.execute <<-SQL.squish
      update user_preferences set forums = array_append(forums, '14')
    SQL
  end

  def down
    UserPreferences.connection.execute <<-SQL.squish
      update user_preferences set forums = array_remove(forums, '14')
    SQL
  end
end
