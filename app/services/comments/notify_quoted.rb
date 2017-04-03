class Comments::NotifyQuoted
  method_object [:old_body, :new_body, :comment, :user]

  ANTISPAM_LIMIT = 15

  def call
    Message.wo_antispam do
      Message.import messages_to_create
    end
    messages_to_destroy.each(&:destroy)
  end

private

  def messages_to_create
    users_to_notify.map do |user|
      Message.new(
        to: user,
        from: @user,
        kind: MessageType::QuotedByUser,
        linked: @comment
      )
    end
  end

  # rubocop:disable AbcSize
  def users_to_notify
    users = new_quoted.users - old_quoted.users
    return [] if users.none?

    ignores = Ignore.where(user_id: users.map(&:id), target: @user)
    notifications = notifications_scope(users).to_a

    users.select do |user|
      ignores.none? { |ignore| ignore.user_id == user.id } &&
        notifications.none? { |message| message.to_id == user.id }
    end
  end
  # rubocop:enable AbcSize

  def messages_to_destroy
    users = old_quoted.users - new_quoted.users
    return [] if users.none?

    notifications_scope users
  end

  def notifications_scope users
    Message.where(
      to_id: users.map(&:id),
      from: @user,
      kind: MessageType::QuotedByUser,
      linked: @comment
    )
  end

  def old_quoted
    @old_quoted ||= extract_quoted_service.call @old_body
  end

  def new_quoted
    @new_quoted ||= extract_quoted_service.call @new_body
  end

  def extract_quoted_service
    @extract_quoted_service ||= Comments::ExtractQuoted.new
  end
end

# notified_comments = []
# notified_users = []

# quotes.each_with_index do |(quoted_comment, quoted_user), index|
  # next if index > ANTISPAM_LIMIT

  # if quoted_comment && !notified_comments.include?(quoted_comment.id)
    # notified_comments << quoted_comment.id
    # ReplyService.new(quoted_comment).append_reply @comment
  # end

  # if quoted_user && quoted_user.id != @comment.user_id &&
      # !notified_users.include?(quoted_user.id) &&
      # !quoted_user.ignores?(@comment.user)

    # notified_users << quoted_user.id

    # Message.create_wo_antispam!(
      # to: quoted_user,
      # from: @comment.user,
      # kind: MessageType::QuotedByUser,
      # linked: @comment
    # )
  # end
# end
