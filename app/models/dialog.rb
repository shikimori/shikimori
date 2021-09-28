class Dialog
  include ActiveModel::Serialization
  vattr_initialize :user, :message

  delegate :created_at, to: :message

  def target_user
    my_message? ? message.to : message.from
  end

  def read
    my_message? || message.read
  end

  def my_message?
    message.from_id == user.id
  end

  def html_body
    BbCodes::Text.call message.body
  end

  def message
    @decorated_message ||= @message.decorate
  end

  def messages
    @messages ||= DialogQuery
      .new(user, target_user)
      .fetch(1, DialogQuery::ALL, false)
      .map(&:decorate)
  end

  def destroy
    messages.each { |message| message.delete_by user }
  end

  def new_message
    @new_message ||= Message.new(
      from_id: user.id,
      to_id: target_user.id,
      kind: MessageType::PRIVATE
    )
  end

  def faye_channel
    ["dialog-#{[user.id, target_user.id].sort.join '-'}"]
  end
end
