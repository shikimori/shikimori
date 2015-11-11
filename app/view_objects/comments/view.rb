class Comments::View < ViewObjectBase
  vattr_initialize :comment, :is_reply

  delegate :bans, :abuse_requests, :user, to: :comment
  instance_cache :decorated_comment, :replies, :reply_ids

  def decorated_comment
    SolitaryCommentDecorator.new comment
  end

  def replies
    Comment
      .where(id: reply_ids)
      .includes(:user)
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
      body: is_reply ?
        "[comment=#{comment.id}]#{comment.user.nickname}[/comment], " :
        ''
    )
  end

  def cached_comments?
    true
  end

  def comments_cache_key
    [
      comment,
      :replies,
      h.russian_names_key,
      Digest::MD5.hexdigest(replies.map(&:cache_key).join(' '))
    ]
  end

private

  def reply_ids
    ReplyService.new(comment).reply_ids
  end
end
