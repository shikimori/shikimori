class Animes::Filters::ByDesynced < Animes::Filters::FilterBase
  dry_type Types::String

  def call
    scope = @scope

    positives.each do |term|
      scope = scope.where term_sql(term)
    end
    negatives.each do |term|
      scope = scope.where.not term_sql(term)
    end

    scope
  end

private

  def term_sql term
    "#{sanitize term} = any(desynced)"
  end
end
