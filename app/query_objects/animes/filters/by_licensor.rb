class Animes::Filters::ByLicensor < Animes::Filters::FilterBase
  # dry_type Types::Anime::Rating
  # field :rating

  def call
    fail_with_scope! unless anime?

    scope = @scope

    scope = scope.where(licensor: positives) if positives.any?
    scope = scope.where.not(licensor: negatives) if negatives.any?

    scope
  end
end
