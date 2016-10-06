class JsExports::CommentsExport < JsExports::ExportBase
private

  def fetch_entries user
    Comment
      .with_viewed(user)
      .where(id: tracked_ids)
      .includes(:topic)
      .select(
        "comments.id, comments.created_at, #{Comment::VIEWED_JOINS_SELECT}"
      )
      .order(:id)
  end

  def serialize comment, user
    ability = Ability.new user

    {
      can_destroy: ability.can?(:destroy, comment),
      can_edit: ability.can?(:edit, comment),
      can_broadcast: can_broadcast?(comment, ability),
      id: comment.id,
      is_viewed: comment.viewed?,
      user_id: comment.user_id
    }
  end

  def can_broadcast? comment, ability
    comment.commentable_type == Topic.name &&
      comment.commentable.is_a?(Topics::EntryTopics::ClubTopic) &&
      ability.can?(:broadcast, comment)
  end
end
