class MigrateStylesFieldsValuesFromUsersToUserPreferences < ActiveRecord::Migration
  def up
    User.includes(:preferences).find_each do |user|
      user.preferences.page_background = user.page_background
      user.preferences.body_background = user.body_background
      user.preferences.page_border = user.page_border
      user.preferences.show_smileys = user.smileys
      user.preferences.show_social_buttons = user.social
      user.preferences.save
    end
  end

  def down
    User.includes(:preferences).find_each do |user|
      user.page_background = user.preferences.page_background
      user.body_background = user.preferences.body_background
      user.page_border = user.preferences.page_border
      user.smileys = user.preferences.show_smileys
      user.social = user.preferences.show_social_buttons
      user.save
    end
  end
end
