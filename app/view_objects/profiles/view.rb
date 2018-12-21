class Profiles::View < ViewObjectBase
  vattr_initialize :user

  BANNED_PROFILES = %w[7683]

  def history_view
    @history_view ||= Profiles::HistoryView.new @user
  end

  def achievements_preview_view
    @achievements_preview_view ||= Profiles::AchievementsPreviewView.new @user
  end

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
      BbCodes::Text.call @user.about || ''
    end
  end

  def avatar_url size = 160
    @user.avatar_url size, own_profile?
  end
end
