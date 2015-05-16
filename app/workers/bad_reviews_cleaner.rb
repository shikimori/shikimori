class BadReviewsCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    bad_reviews.each { |review| review.reject!(BotsService.get_poster) }
  end

private

  def bad_reviews
    reviews.select { |review| low_level? review }
  end

  def reviews
    @reviews ||= Review
      .where(state: 'pending')
      .where('created_at < ?', 1.day.ago)
      .to_a
  end

  def votes
    @vites ||= Vote
      .where(voteable_type: Review.name, voteable_id: reviews.map(&:id))
      .where.not(user_id: User.suspicious)
      .to_a
  end

  def low_level? review
    review_votes = votes.select {|v| v.voteable_id == review.id }

    votes_for = review_votes.count {|v| v.voting }
    votes_against = review_votes.count {|v| !v.voting }

    votes_against > 30 && (votes_for * 1.0 / votes_against) < 0.25
  end
end
