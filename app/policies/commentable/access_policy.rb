class Commentable::AccessPolicy
  static_facade :allowed?, :commentable, :current_user

  def allowed?
    return false unless @commentable
    return true if moderator?

    case commentable
      when Topic
        Topic::AccessPolicy.allowed? @commentable, @current_user

      when User
        profile_access? commentable
    end
  end

private

  def profile_access? user
    return true if user == @current_user

    !!(
      user.preferences.comments_in_profile? && !user.censored_profile?
    )
  end

  def moderator?
    @current_user&.moderation_staff?
  end
end
