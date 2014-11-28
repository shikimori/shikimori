class Dialog
  vattr_initialize :user, :message

  def target_user
    my_message? ? message.to : message.from
  end

  def created_at
    message.created_at
  end

  def read
    my_message? || message.read
  end

  def my_message?
    message.from_id == user.id
  end

  def html_body
    BbCodeFormatter.instance.format_comment message.body
  end

  def messages
    @messages ||= DialogQuery
      .new(user, target_user)
      .fetch(1, DialogQuery::ALL)
  end

  def destroy
    messages.each do |message|
      message.delete_by user
    end
  end

  def new_message
    Message.new from_id: user.id, to_id: target_user.id, kind: MessageType::Private
  end

  def faye_channel
    ["dialog-#{[user.id, target_user.id].sort.join '-'}"]
  end
end
