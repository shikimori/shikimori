class Profiles::View < ViewObjectBase
  vattr_initialize :user

  instance_cache :achievements_preview_view

  BANNED_PROFILES = %w[7683]

  def own_profile?
    h.user_signed_in? && h.current_user.id == @user.id
  end

  def banned_profile?
    BANNED_PROFILES.include?(@user.id.to_s) && !own_profile?
  end

  def show_comments?
    !banned_profile? &&
      (h.user_signed_in? || @user.comments.any?) &&
      @user.preferences.comments_in_profile?
  end

  def about_html
    return if banned_profile?

    Rails.cache.fetch [:about, @user] do
      BbCodes::Text.call about || ''
    end
  end

  def avatar_url size = 160
    @user.avatar_url size, own_profile?
  end

  def achievements_preview_view
    Profiles::AchievementsPreviewView.new user
  end
end
