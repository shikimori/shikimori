class ReviewsQuery
  NewReviewBubbleInterval = 2.days

  def initialize entry, user, locale, id = 0
    @entry = entry
    @user = user
    @locale = locale
    @id = id
  end

  def fetch
    reviews = @entry.reviews
      .includes(:user, :topics)
      .where(locale: @locale)

    if @id.present? && @id != 0
      reviews.where(id: @id)
    else
      reviews = reviews.visible
      [
        reviews
          .select { |v| v.created_at + NewReviewBubbleInterval > DateTime.now }
          .sort_by { |v| - v.id },
        reviews
          .select { |v| v.created_at + NewReviewBubbleInterval <= DateTime.now }
          .sort_by { |v| -(v.cached_votes_up - v.cached_votes_down) }
      ].compact.flatten.uniq
    end
  end
end
