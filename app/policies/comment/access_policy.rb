class Comment::AccessPolicy
  static_facade :allowed?, :comment, :current_user

  def allowed?
    return true if own_comment?

    Commentable::AccessPolicy.allowed? @comment.commentable, @current_user
  end

private

  def own_comment?
    @comment.user_id == @current_user&.id
  end
end
