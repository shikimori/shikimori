class Animes::Filters::ByPublisher < Animes::Filters::FilterBase
  dry_type Types::Integer.constructor ->(value) {
    fixed_value = value.to_i
    Publisher::MERGED[fixed_value] || fixed_value
  }
  field :publisher

  def call
    fail_with_scope! if anime?

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
    term_with_clones = Publisher.related(term.to_i)
    "publisher_ids && '{#{term_with_clones.join(',')}}'"
  end
end
