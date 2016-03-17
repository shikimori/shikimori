class ReviewsQuery
  NewReviewBubbleInterval = 2.days

  def initialize entry, user, id = 0
    @entry = entry
    @user = user
    @id = id
  end

  def fetch
    reviews = @entry.reviews.includes(:user, :votes, :topic)

    if @id.present? && @id != 0
      reviews.where(id: @id)
    else

      reviews = reviews.visible
      [
        reviews.select { |v| v.created_at + NewReviewBubbleInterval > DateTime.now }.sort_by { |v| - v.id },
        reviews.select { |v| v.created_at + NewReviewBubbleInterval <= DateTime.now }.sort_by { |v| -(v.votes_for - v.votes_against) }
      ].compact.flatten.uniq
    end
  end
end
