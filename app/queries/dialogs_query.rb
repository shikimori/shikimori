class DialogsQuery
  pattr_initialize :user

  def fetch page, limit
    Message
      .where(id: latest_message_ids)
      .includes(:linked, :from, :to)
      .order(id: :desc)
      .offset(limit * (page-1))
      .limit(limit + 1)
  end

  def postload page, limit
    collection = fetch(page, limit).to_a
    [collection.take(limit), collection.size == limit+1]
  end

private
  def latest_message_ids
    Message
      .where(kind: MessageType::Private)
      .where.not(from_id: ignores_ids, to_id: ignores_ids)
      .where("from_id = :user_id or to_id = :user_id", user_id: user.id)
      .group("case when from_id = #{user.id} then to_id else from_id end")
      .order('max(id) desc')
      .select('max(id) as id')
      .map(&:id)
  end

  def ignores_ids
    @ignores_ids ||= user.ignores.map(&:target_id) << 0
  end
end
