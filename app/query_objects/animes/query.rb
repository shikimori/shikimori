class Animes::Query < QueryObjectBase
  def self.fetch klass:, params:, user:
    new(klass.all)
      .by_kind(params[:kind])
      .by_rating(params[:rating])
  end

  def by_kind value
    return self if value.blank?

    chain Animes::Filters::ByKind.call(@scope, value)
  end

  def by_rating value
    return self if value.blank?

    chain Animes::Filters::ByRating.call(@scope, value)
  end
end
