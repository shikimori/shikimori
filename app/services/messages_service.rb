class MessagesService
  pattr_initialize :user

  def read_messages kind: nil, type: nil
    Message
      .where(to: user, kind: kind || kinds_by_type(type), read: false)
      .update_all(read: true)
  end

  def delete_messages kind: nil, type: nil
    Message
      .where(to: user, kind: kind || kinds_by_type(type))
      .delete_all
  end

private
  def kinds_by_type type
    MessagesQuery.new(user, type).kinds_by_type
  end
end
