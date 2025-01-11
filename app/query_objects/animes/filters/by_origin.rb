class Animes::Filters::ByOrigin < Animes::Filters::FilterBase
  dry_type Types::Anime::Origin
  field :rating

  def call
    fail_with_scope! unless anime?

    scope = @scope

    scope = scope.where(origin: positives) if positives.any?
    scope = scope.where.not(origin: negatives) if negatives.any?

    scope
  end
end
