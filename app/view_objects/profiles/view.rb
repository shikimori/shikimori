class Profiles::View < ViewObjectBase
  vattr_initialize :user

  instance_cache :achievements_preview_view

  def own_profile?
    h.user_signed_in? && h.current_user.id == @user.id
  end

  def avatar_url size = 160
    @user.avatar_url size, own_profile?
  end

  def achievements_preview_view
    Profiles::AchievementsPreviewView.new user
  end
end
