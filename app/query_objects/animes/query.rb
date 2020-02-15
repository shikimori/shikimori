class Animes::Query < QueryObjectBase
  GENRES_EXCLUDED_BY_SEX = {
    'male' => Genre::YAOI_IDS + Genre::SHOUNEN_AI_IDS,
    'female' => Genre::HENTAI_IDS + Genre::SHOUJO_AI_IDS + Genre::YURI_IDS,
    '' => Genre::CENSORED_IDS + Genre::SHOUNEN_AI_IDS + Genre::SHOUJO_AI_IDS
  }

  DEFAULT_ORDER = Animes::Filters::OrderBy::Field[:ranked]
  SEARCH_IDS_LIMIT = 250

  def self.fetch scope:, params:, user: # rubocop:disable AbcSize, MethodLength
    new(scope)
      .by_achievement(params[:achievement])
      .by_duration(params[:duration])
      .by_exclude_ids(params[:exclude_ids])
      .by_franchise(params[:franchise])
      .by_genre(params[:genre])
      .by_ids(params[:ids])
      .by_kind(params[:kind])
      .by_publisher(params[:publisher])
      .by_rating(params[:rating])
      .by_score(params[:score])
      .by_season(params[:season])
      .by_status(params[:status])
      .by_studio(params[:studio])
      .by_user_list(params[:mylist], user)
      .order_by(params[:order] || DEFAULT_ORDER)
      .search(params[:search] || params[:q] || params[:phrase])
      # "phrase" is used in collection-search (userlist comparer)
  end

  def by_achievement value
    return self if value.blank?

    chain Animes::Filters::ByAchievement.call(@scope, value)
  end

  def by_duration value
    return self if value.blank?

    chain Animes::Filters::ByDuration.call(@scope, value)
  end

  def by_exclude_ids value
    return self if value.blank?

    chain @scope.where.not(id: value.is_a?(String) ? value.split(',') : value)
  end

  def by_franchise value
    return self if value.blank?

    chain Animes::Filters::ByFranchise.call(@scope, value)
  end

  def by_genre value
    return self if value.blank?

    chain Animes::Filters::ByGenre.call(@scope, value)
  end

  def by_ids value
    return self if value.blank?

    chain @scope.where(id: value.is_a?(String) ? value.split(',') : value)
  end

  def by_kind value
    return self if value.blank?

    chain Animes::Filters::ByKind.call(@scope, value)
  end

  def by_publisher value
    return self if value.blank?

    chain Animes::Filters::ByPublisher.call(@scope, value)
  end

  def by_rating value
    return self if value.blank?

    chain Animes::Filters::ByRating.call(@scope, value)
  end

  def by_score value
    return self if value.blank?

    chain Animes::Filters::ByScore.call(@scope, value)
  end

  def by_season value
    return self if value.blank?

    chain Animes::Filters::BySeason.call(@scope, value)
  end

  def by_status value
    return self if value.blank?

    chain Animes::Filters::ByStatus.call(@scope, value)
  end

  def by_studio value
    return self if value.blank?

    chain Animes::Filters::ByStudio.call(@scope, value)
  end

  def by_user_list value, user
    return self if value.blank? || user.nil?

    chain Animes::Filters::ByUserList.call(@scope, value, user)
  end

  def exclude_ai_genres sex
    excludes = GENRES_EXCLUDED_BY_SEX[sex || '']

    chain Animes::Filters::ByGenre.call(@scope, "!#{excludes.join ',!'}")
  end

  def order_by value
    return self if value.blank?

    chain Animes::Filters::OrderBy.call(@scope, value)
  end

  def search value
    return self if value.blank?

    chain "Search::#{@scope.klass.name}".constantize.call(
      scope: @scope,
      phrase: value,
      ids_limit: SEARCH_IDS_LIMIT
    )
  end
end
