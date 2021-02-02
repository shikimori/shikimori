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

  def serialize comment, user
    ability = Ability.new user

    {
      can_destroy: ability.can?(:destroy, comment),
      can_edit: ability.can?(:edit, comment),
      id: comment.id,
      is_viewed: comment.viewed?,
      user_id: comment.user_id
    }
  end
end
