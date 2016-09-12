class JsExports::TopicsExport < JsExports::ExportBase
private

  def fetch_entries user
    Topic
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("topics.id, topics.created_at, #{Topic::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize topic, user
    ability = Ability.new user
    {
      can_destroy: ability.can?(:destroy, topic),
      can_edit: ability.can?(:edit, topic),
      id: topic.id,
      is_viewed: topic.viewed?,
      user_id: topic.user_id
    }
  end
end
