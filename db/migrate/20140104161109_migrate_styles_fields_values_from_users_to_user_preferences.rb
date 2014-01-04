class MigrateStylesFieldsValuesFromUsersToUserPreferences < ActiveRecord::Migration
  def up
    User.find_each do |user|
      user.preferences.page_background = user.page_background
      user.preferences.body_background = user.body_background
      user.preferences.page_border = user.page_border
      user.preferences.save
    end
  end

  def down
    User.find_each do |user|
      user.page_background = user.preferences.page_background
      user.body_background = user.preferences.body_background
      user.page_border = user.preferences.page_border
      user.save
    end
  end
end
