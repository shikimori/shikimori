class Animes::Filters::ByDuration < Animes::Filters::FilterBase
  Duration = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:S, :D, :F)

  dry_type Duration

  DURATION_SQL = {
    Duration[:S] => '(duration >= 0 and duration <= 10)',
    Duration[:D] => '(duration > 10 and duration <= 30)',
    Duration[:F] => '(duration > 30)'
  }

  def call
    scope = @scope

    if positives.any?
      sql = positives
        .map { |duration| DURATION_SQL[duration] }
        .join(' or ')

      scope = scope.where(sql)
    end

    if negatives.any?
      sql = negatives
        .map { |duration| DURATION_SQL[duration] }
        .join(' or ')

      scope = scope.where("not (#{sql})")
    end

    scope
  end
end
