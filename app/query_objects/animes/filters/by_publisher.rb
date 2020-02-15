class Animes::Filters::ByPublisher < Animes::Filters::FilterBase
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
    term_with_clones = Publisher.related(term.to_i)
    "publisher_ids && '{#{term_with_clones.join(',')}}'"
  end
end
