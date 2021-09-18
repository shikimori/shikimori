class BadCritiquesCleaner
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  MINIMUM_VOTES = 35

  def perform
    bad_reviews.each do |review|
      review.reject! rejecter, "Рецензию оценили минимум #{MINIMUM_VOTES} человек, из которых более 80% оставили негативную оценку."
    end
  end

private

  def rejecter
    @rejecter ||= User.find User::MESSANGER_ID
  end

  def bad_reviews
    reviews.select { |review| low_level? review }
  end

  def reviews
    @reviews ||= Critique.where(moderation_state: 'pending').to_a
  end

  def votes
    @vites ||= Vote
      .where(voteable_type: Critique.name, voteable_id: reviews.map(&:id))
      .where.not(user_id: User.suspicious)
      .to_a
  end

  def low_level? review
    votes_total = review.cached_votes_up + review.cached_votes_down

    votes_total >= MINIMUM_VOTES &&
      (review.cached_votes_down / votes_total) >= 0.8
  end
end
