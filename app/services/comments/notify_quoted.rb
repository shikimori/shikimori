class Comments::NotifyQuoted
  method_object %i[old_body new_body comment user]

  ANTISPAM_LIMIT = 15

  def call
    Message.wo_antispam do
      Message.import messages_to_create
    end
    messages_to_destroy.each(&:destroy)

    reply new_quoted.models - old_quoted.models, :append
    reply old_quoted.models - new_quoted.models, :remove
  end

private

  def reply models, action
    models.each do |model|
      Comments::Reply.new(model).send :"#{action}_reply", @comment
    end
  end

  def messages_to_create
    users_to_notify.map do |user|
      Message.new(
        to: user,
        from: @user,
        kind: MessageType::QUOTED_BY_USER,
        linked: @comment
      )
    end
  end

  def users_to_notify
    return [] if quoted_users.none?

    users = quoted_users

    ignores = Ignore.where(user_id: users.map(&:id), target: @user)
    notifications = notifications_scope(users).to_a

    users.filter! do |user|
      ignores.none? { |ignore| ignore.user_id == user.id } &&
        notifications.none? { |message| message.to_id == user.id }
    end

    users
      .filter(&:notification_settings_mention_event?)
      .filter { |user| Comment::AccessPolicy.allowed? @comment, user }
  end

  def quoted_users
    (new_quoted.users - old_quoted.users)
      .reject { |user| user.id == @user.id }
  end

  def messages_to_destroy
    users = old_quoted.users - new_quoted.users
    return [] if users.none?

    notifications_scope users
  end

  def notifications_scope users
    Message.where(
      to_id: users.map(&:id),
      from: @user,
      kind: MessageType::QUOTED_BY_USER,
      linked: @comment
    )
  end

  def old_quoted
    @old_quoted ||= Comments::ExtractQuotedModels.call(
      (BbCodes::UserMention.call(@old_body) if @old_body)
    )
  end

  def new_quoted
    @new_quoted ||= Comments::ExtractQuotedModels.call(
      (BbCodes::UserMention.call(@new_body) if @new_body)
    )
  end
end
