class BadReviewsCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    bad_reviews.each do |review|
      review.reject! rejecter, "Рецензию оценили минимум 50 человек, из которых более 80% оставили негативную оценку."
    end
  end

private

  def rejecter
    @rejecter ||= User.find User::Cosplayer_ID
  end

  def bad_reviews
    reviews.select { |review| low_level? review }
  end

  def reviews
    @reviews ||= Review
      .where(state: 'pending')
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

    votes_count = review_votes.size * 1.0
    votes_against = review_votes.count {|v| !v.voting }

    votes_count > 10 && (votes_against / votes_count) >= 0.8
  end
end
