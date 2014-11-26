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
end
