class Animes::Query < QueryObjectBase
  def self.fetch scope:, params:, user:
    new(scope)
      .by_achievement(params[:achievement])
      .by_duration(params[:duration])
      .by_franchise(params[:franchise])
      .by_ids(params[:ids])
      .by_kind(params[:kind])
      .by_rating(params[:rating])
      .by_score(params[:score])
      .by_status(params[:status])
  end

  def by_achievement value
    return self if value.blank?

    chain Animes::Filters::ByAchievement.call(@scope, value)
  end

  def by_duration value
    return self if value.blank?

    chain Animes::Filters::ByDuration.call(@scope, value)
  end

  def by_franchise value
    return self if value.blank?

    chain Animes::Filters::ByFranchise.call(@scope, value)
  end

  def by_ids value
    return self if value.blank?

    chain @scope.where(id: value.is_a?(String) ? value.split(',') : value)
  end

  def by_kind value
    return self if value.blank?

    chain Animes::Filters::ByKind.call(@scope, value)
  end

  def by_rating value
    return self if value.blank?

    chain Animes::Filters::ByRating.call(@scope, value)
  end

  def by_score value
    return self if value.blank?

    chain Animes::Filters::ByScore.call(@scope, value)
  end

  def by_status value
    return self if value.blank?

    chain Animes::Filters::ByStatus.call(@scope, value)
  end
end
