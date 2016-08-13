class JsExports::TopicsExport < JsExports::ExportBase
private

  def fetch_entries user
    Topic
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("entries.id, entries.created_at, #{Topic::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize entry
    { id: entry.id, is_viewed: entry.viewed? }
  end
end
