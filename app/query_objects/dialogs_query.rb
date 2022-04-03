class DialogsQuery < SimpleQueryBase
  pattr_initialize :user

  WHREE_SQL = <<-SQL.squish
    from_id = :user_id or (to_id = :user_id and is_deleted_by_to=false)
  SQL

  def fetch page, limit
    Message
      .where(id: latest_message_ids(page, limit))
      .includes(:linked, :from, :to)
      .order(id: :desc)
      .map { |message| Dialog.new user, message }
  end

private

  def latest_message_ids page, limit # rubocop:disable AbcSize
    Message
      .where(kind: MessageType::PRIVATE)
      .where.not(from_id: ignores_ids)
      .where.not(to_id: ignores_ids)
      .where(Arel.sql(WHREE_SQL), user_id: user.id)
      .group(
        Arel.sql("case when from_id = #{user.id} then to_id else from_id end")
      )
        .order(Arel.sql('max(id) desc'))
      .select('max(id) as id')
      .offset(limit * (page - 1))
      .limit(limit + 1)
  end

  def ignores_ids
    @ignores_ids ||= user.ignores.map(&:target_id) << 0
  end
end
