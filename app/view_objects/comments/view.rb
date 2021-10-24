class Comments::View < Topics::FoldedCommentsView
  vattr_initialize :comment, :is_reply

  delegate :bans, :abuse_requests, :user, to: :comment
  instance_cache :decorated_comment, :comments, :reply_ids

  def ignored_user?
    h.user_signed_in? && h.current_user.ignores?(user)
  end

  def decorated_comment
    SolitaryCommentDecorator.new comment
  end

  def comments_scope
    Comment
      .where(id: reply_ids)
      .includes(:user, :commentable)
      .order(created_at: :desc)
  end

  def fetch_url
    h.replies_comments_url(
      comment_id: @comment.id,
      skip: 'SKIP',
      limit: fold_limit
    )
  end

  def new_comment
    Comment.new(
      user: h.current_user,
      commentable_id: comment.commentable_id,
      commentable_type: comment.commentable_type,
      body: is_reply ?
        "[comment=#{comment.id};#{comment.user_id}], " :
        ''
    )
  end

  def cache_key
    CacheHelper.keys(
      @comment.cache_key,
      *comments.map(&:cache_key_with_version)
    )
  end

  def comments_count
    reply_ids.size
  end

  def faye_channels
    comments.map(&:id).push(@comment.id).map { |id| "/comment-#{id}" }
  end

private

  def reply_ids
    Comments::Reply.new(comment).reply_ids
  end
end
