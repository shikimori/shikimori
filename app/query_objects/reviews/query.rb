class Reviews::Query
  NEW_REVIEW_BUBBLE_INTERVAL = 2.days

  def initialize entry, user, id = 0
    @entry = entry
    @user = user
    @id = id
  end

  def fetch
    reviews = @entry.reviews
      .includes(:user)

    if @id.present? && @id != 0
      reviews.where(id: @id)
    else
      reviews = reviews.visible
      [
        bubbled(reviews),
        not_bubbled(reviews)
      ].compact.flatten.uniq
    end
  end

private

  def bubbled reviews
    reviews
      .select { |v| v.created_at + NEW_REVIEW_BUBBLE_INTERVAL > Time.zone.now }
      .sort_by { |v| - v.id }
  end

  def not_bubbled reviews
    reviews
      .select { |v| v.created_at + NEW_REVIEW_BUBBLE_INTERVAL <= Time.zone.now }
      .sort_by { |v| -(v.cached_votes_up - v.cached_votes_down) }
  end
end
