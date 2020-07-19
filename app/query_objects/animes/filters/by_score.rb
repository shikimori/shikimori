class Animes::Filters::ByScore < Animes::Filters::FilterBase
  Score = Types::Coercible::Integer.enum(1, 2, 3, 4, 5, 6, 7, 8, 9)

  dry_type Score
  field :score

  def call
    scope = @scope

    if positives.any?
      sql = positives
        .map { |score| format("%<table_name>s.score >= #{score}", table_name: scope.table_name) }
        .join(' or ')

      scope = scope.where(sql)
    end

    fail_with_negative! if negatives.any?

    scope
  end
end
