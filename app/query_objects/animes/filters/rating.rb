class Animes::Filters::Rating < Animes::Filters::FilterBase
  def call
    scope = @scope

    scope = scope.where(rating: positives) if positives.any?
    scope = scope.where.not(rating: negatives) if negatives.any?

    scope
  end
end
