class User::NotifyProfileCommented
  method_object :comment

  NON_PROFILE_COMMENT_ERROR_MESSAGE = 'non profile comment#%<comment_id>i'
  MESSAGE_KIND = MessageType::PROFILE_COMMENTED

  def call
    throw_error! unless profile_comment?
    return if own_profile?
    return if unread_notifiaction?

    Message.create(
      to_id: profile_id,
      from_id: @comment.user_id,
      kind: MESSAGE_KIND
    )
  end

private

  def profile_comment?
    @comment.commentable_type == User.name
  end

  def own_profile?
    @comment.user_id == @comment.commentable_id
  end

  def profile_id
    comment.commentable_id
  end

  def unread_notifiaction?
    Message
      .where(
        kind: MESSAGE_KIND,
        to_id: profile_id,
        from_id: @comment.user_id,
        read: false
      )
      .any?
  end

  def throw_error!
    raise ArgumentError, format(
      NON_PROFILE_COMMENT_ERROR_MESSAGE,
      comment_id: @comment.id
    )
  end
end
