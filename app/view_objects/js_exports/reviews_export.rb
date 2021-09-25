class JsExports::ReviewsExport < JsExports::ExportBase
  private

  def fetch_entries user
    Review
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("reviews.id, reviews.created_at, #{Review::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize review, user, ability
    {
      can_destroy: ability.can?(:destroy, review),
      can_edit: ability.can?(:edit, review),
      id: review.id,
      is_viewed: review.viewed?,
      user_id: review.user_id,
      voted_yes: user.liked?(review),
      voted_no: user.disliked?(review),
      votes_for: review.cached_votes_up,
      votes_against: review.cached_votes_down
    }
  end
end
