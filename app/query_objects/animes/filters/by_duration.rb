class Animes::Filters::ByDuration < Animes::Filters::FilterBase
  Duration = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:S, :D, :F)

  dry_type Duration
  field :duration

  SQL_QUERIES = {
    Duration[:S] => '(duration >= 0 and duration <= 10)',
    Duration[:D] => '(duration > 10 and duration <= 30)',
    Duration[:F] => '(duration > 30)'
  }

  def call
    fail_with_scope! unless anime?

    scope = @scope

    scope = apply_positives scope if positives.any?
    scope = apply_negatives scope if negatives.any?

    scope
  end

private

  def apply_positives scope
    sql = positives.map { |term| SQL_QUERIES[term] }.join(' or ')
    scope.where(sql)
  end

  def apply_negatives scope
    sql = negatives.map { |term| SQL_QUERIES[term] }.join(' or ')
    scope.where("not (#{sql})")
  end
end
