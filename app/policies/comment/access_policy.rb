class Comment::AccessPolicy
  static_facade :allowed?, :comment, :current_user

  def allowed?
    topic = @comment.commentable
    return true unless topic.is_a? Topic

    Topic::AccessPolicy.allowed? topic, @current_user
  end
end
