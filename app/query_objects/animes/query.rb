class Animes::Query < QueryObjectBase
  def self.fetch scope:, params:, user:
    new(scope)
      .by_kind(params[:kind])
      .by_rating(params[:rating])
      .by_duration(params[:duration])
  end

  def by_kind value
    return self if value.blank?

    chain Animes::Filters::ByKind.call(@scope, value)
  end

  def by_rating value
    return self if value.blank?

    chain Animes::Filters::ByRating.call(@scope, value)
  end

  def by_duration value
    return self if value.blank?

    chain Animes::Filters::ByDuration.call(@scope, value)
  end
end
