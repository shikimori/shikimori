class MessagesService
  pattr_initialize :user

  def read_messages kind: nil, type: nil
    Message
      .where(to: user, kind: kind || kinds_by_type(type), read: false)
      .where("not (kind in (?) and read = false)", MessageType::RESPONSE_REQUIRED)
      .update_all(read: true)
  end

  def delete_messages kind: nil, type: nil
    Message
      .where(to: user, kind: kind || kinds_by_type(type))
      .where("not (kind in (?) and read = false)", MessageType::RESPONSE_REQUIRED)
      .delete_all
  end

private
  def kinds_by_type type
    MessagesQuery.new(user, type).where_by_type[:kind]
  end
end
