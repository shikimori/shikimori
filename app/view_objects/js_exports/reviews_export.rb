class JsExports::ReviewsExport < JsExports::ExportBase
  private

  def fetch_entries user
    Review
      .with_viewed(user)
      .where(id: tracked_ids)
      .select("reviews.id, reviews.created_at, #{Review::VIEWED_JOINS_SELECT}")
      .order(:id)
  end

  def serialize review, user
    ability = Ability.new user

    {
      can_destroy: can_destroy?(ability, review),
      can_edit: can_edit?(ability, review),
      id: review.id,
      is_viewed: review.viewed?,
      user_id: review.user_id
      # voted_yes: user.liked?(review.linked),
      # voted_no: user.disliked?(review.linked),
      # votes_for: review.linked.cached_votes_up,
      # votes_against: review.linked.cached_votes_down
    }
  end

  def can_edit? ability, review
    ability.can? :edit, review
  end

  def can_destroy? ability, review
    ability.can? :destroy, review
  end
end
