class Comment::AccessPolicy
  static_facade :allowed?, :comment, :current_user

  # CENSORED_CLUB_COMMENT_EXPIRATION_INTERVAL = 6.months

  def allowed?
    commentable = @comment.commentable
    return true if own_comment?

    case commentable
      when Topic
        Topic::AccessPolicy.allowed? commentable, @current_user

      when User
        profile_access? commentable
    end
  end

private

  def own_comment?
    @current_user && @comment.user_id == @current_user.id
  end

  def profile_access? user
    !!(
      user&.preferences&.comments_in_profile? && !user.censored_profile?
    )
  end
end
