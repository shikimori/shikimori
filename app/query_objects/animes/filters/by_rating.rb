class Animes::Filters::ByRating < Animes::Filters::FilterBase
  dry_type Types::Anime::Rating

  def call
    scope = @scope

    scope = scope.where(rating: positives) if positives.any?
    scope = scope.where.not(rating: negatives) if negatives.any?

    scope
  end
end
