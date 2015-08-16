class DialogQuery
  pattr_initialize :user, :target_user

  ALL = 999

  def fetch page, limit, dynamic
    if dynamic
      dynamic_limit = page > 1 ? limit : 3
      dynamic_offset = page > 1 && limit != ALL ? limit - 3 : 0
    else
      dynamic_limit = limit
      dynamic_offset = 0
    end

    Message
      .where(kind: MessageType::Private)
      .where(
        "(from_id = :user_id and to_id = :target_user_id and is_deleted_by_from=false) or
         (from_id = :target_user_id and to_id = :user_id and is_deleted_by_to=false)",
        user_id: user.id, target_user_id: target_user.id)
      .includes(:linked, :from, :to)
      .order(id: :desc)
      .offset(dynamic_limit * (page-1) - dynamic_offset)
      .limit(dynamic_limit + 1)
      .decorate
      .reverse
  end

  def postload page, limit
    dynamic_limit = page > 1 ? limit : 3
    collection = fetch page, limit, true

    if collection.size == dynamic_limit+1
      [collection.drop(1), true]
    else
      [collection, false]
    end
  end
end
