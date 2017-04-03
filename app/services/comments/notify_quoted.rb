class Comments::NotifyQuoted
  method_object [:old_body, :new_body, :comment, :user]

  ANTISPAM_LIMIT = 15

  def call
    notify_messages
    notify_quotes
  end

private

  def notify_messages
    Message.wo_antispam do
      Message.import messages_to_create
    end
    messages_to_destroy.each(&:destroy)
  end

  # rubocop:disable AbcSize
  def notify_quotes
    (new_quoted.comments - old_quoted.comments).each do |comment|
      ReplyService.new(comment).append_reply @comment
    end

    (old_quoted.comments - new_quoted.comments).each do |comment|
      ReplyService.new(comment).remove_reply @comment
    end
  end
  # rubocop:enable AbcSize

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
