class Animes::Filters::ByGenre < Animes::Filters::FilterBase
  dry_type Types::Integer.constructor(&:to_i)

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
    "genre_ids && '{#{term.to_i}}'"
  end
end
