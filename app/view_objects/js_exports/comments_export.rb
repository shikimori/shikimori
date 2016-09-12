class JsExports::CommentsExport < JsExports::ExportBase
private

  def fetch_entries user
    Comment
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("comments.id, comments.created_at, #{Comment::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize comment, user
    {
      id: comment.id,
      is_viewed: comment.viewed?
    }
  end
end
