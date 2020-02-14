class Animes::Filters::ByScore < Animes::Filters::FilterBase
  Score = Types::Strict::Integer
    .constructor(&:to_i)
    .enum(1, 2, 3, 4, 5, 6, 7, 8, 9)

  dry_type Score

  def call
    scope = @scope

    if positives.any?
      sql = positives
        .map { |score| "score >= #{score}" }
        .join(' or ')

      scope = scope.where(sql)
    end

    fail_with negatives[0] if negatives.any?

    scope
  end

private

  def fail_with value
    Score["!#{value}"]
  end
end
