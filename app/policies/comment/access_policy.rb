class Comment::AccessPolicy
  static_facade :allowed?, :comment, :current_user

  def allowed?
    topic = @comment.commentable
    return true if own_comment?
    return true unless topic.is_a? Topic

    Topic::AccessPolicy.allowed? topic, @current_user
  end

private

  def own_comment?
    @current_user && @comment.user_id == @current_user.id
  end
end
