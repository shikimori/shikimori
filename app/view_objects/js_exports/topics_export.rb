class JsExports::TopicsExport < JsExports::ExportBase
private

  def fetch_topics user
    Topic
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("topics.id, topics.created_at, #{Topic::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize topic
    { id: topic.id, is_viewed: topic.viewed? }
  end
end
