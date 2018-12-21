class ProfileView < ViewObjectBase
  vattr_initialize :user
  instance_cache :achievements_preview_view

  def achievements_preview_view
    Profiles::AchievementsPreviewView.new user
  end
end
