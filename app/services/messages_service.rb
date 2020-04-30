class MessagesService
  pattr_initialize :user

  def read kind: nil, type: nil
    Message
      .where(to: user, kind: kind || kinds_by_type(type), read: false)
      .update_all(read: true)

    user.touch
  end

  def delete_messages kind: nil, type: nil
    Message
      .where(to: user, kind: kind || kinds_by_type(type))
      .delete_all

    user.touch
  end

private

  def kinds_by_type type
    MessagesQuery.new(user, type).where_by_type[:kind]
  end
end
