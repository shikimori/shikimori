class Animes::Filters::ByRating < Animes::Filters::FilterBase
  # NOTE: disabled until 01-04-2020
  # dry_type Types::Anime::Rating
  field :rating

  def call
    fail_with_scope! unless anime?

    scope = @scope

    scope = scope.where(rating: positives) if positives.any?
    scope = scope.where.not(rating: negatives) if negatives.any?

    scope
  end
end
