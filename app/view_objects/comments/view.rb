class Comments::View < ViewObjectBase
  vattr_initialize :comment, :is_reply

  delegate :bans, :abuse_requests, :user, to: :comment
  instance_cache :decorated_comment, :replies, :reply_ids

  def ignored_user?
    h.user_signed_in? && h.current_user.ignores?(user)
  end

  def decorated_comment
    SolitaryCommentDecorator.new comment
  end

  def replies
    Comment
      .where(id: reply_ids)
      .includes(:user, :commentable)
      .decorate
      .sort_by { |v| reply_ids.index v.id }
  end

  # Topics::CommentsView compatibility
  def folded?
    false
  end

  def comments
    replies
  end

  def new_comment
    Comment.new(
      user: h.current_user,
      commentable_id: comment.commentable_id,
      commentable_type: comment.commentable_type,
      body: true ?
        "[comment=#{comment.id}]#{comment.user.nickname}[/comment], " :
        ''
    )
  end

  def cached_comments?
    true
  end

private

  def reply_ids
    Comments::Reply.new(comment).reply_ids
  end
end
