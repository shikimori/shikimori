class Animes::Filters::ByLicensor < Animes::Filters::FilterBase
  ANYTHING = 'any'

  def call
    scope = @scope

    scope = apply_positives scope if positives.any?
    scope = apply_negatives scope if negatives.any?

    scope
  end

private

  def apply_positives scope
    meaningful_positives = positives.reject { |v| v == ANYTHING }

    if meaningful_positives.any?
      scope = scope.where(terms_sql(meaningful_positives))
    end

    if meaningful_positives.size != positives.size
      scope = scope.where.not licensors: []
    end

    scope
  end

  def apply_negatives scope
    meaningful_negatives = negatives.reject { |v| v == ANYTHING }

    if meaningful_negatives.any?
      scope = scope.where.not(terms_sql(meaningful_negatives))
    end

    if meaningful_negatives.size != negatives.size
      scope = scope.where licensors: []
    end

    scope
  end

  def terms_sql terms
    sql = terms
      .map { |term| ApplicationRecord.sanitize term, is_double_quotes: true }
      .join(',')

    "licensors && '{#{sql}}'"
  end
end
