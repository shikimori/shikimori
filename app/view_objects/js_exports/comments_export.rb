class JsExports::CommentsExport < JsExports::ExportBase
  private

  def fetch_entries user
    Comment
      .with_viewed(user)
      .where(id: tracked_ids)
      .select(
        "comments.id, comments.created_at, #{Comment::VIEWED_JOINS_SELECT}"
      )
      .order(:id)
      # .includes(:topic)
  end

  def serialize comment, _user, ability
    {
      can_create_abuse_request: _user.can_post?,
      is_own_comment: _user.id == comment.user_id,
      can_destroy: ability.can?(:destroy, comment),
      can_edit: ability.can?(:edit, comment),
      id: comment.id,
      is_viewed: comment.viewed?,
      user_id: comment.user_id
    }
  end
end
