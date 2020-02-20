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
      scope = scope.where licensor: meaningful_positives
    end

    if meaningful_positives.size != positives.size
      scope = scope.where.not licensor: ''
    end

    scope
  end

  def apply_negatives scope
    meaningful_negatives = negatives.reject { |v| v == ANYTHING }

    if meaningful_negatives.any?
      scope = scope.where.not licensor: meaningful_negatives
    end

    if meaningful_negatives.size != negatives.size
      scope = scope.where licensor: ''
    end

    scope
  end
end
