class AnimesCollection::View < ViewObjectBase # rubocop:disable ClassLength
  vattr_initialize :klass, :user

  instance_cache :collection, :results
  delegate :page, :pages_count, to: :results

  OVA_KEY = 'OVA/ONA'
  PAGE_LIMIT = 20
  SEASON_LIMIT = 1000

  DEFAULT_ORDER = Animes::Filters::OrderBy::DEFAULT_ORDER
  CACHE_VERSION = 27

  def collection
    if season_page?
      results.collection
        .map(&:decorate)
        .group_by { |v| anime_ova_ona?(v) ? OVA_KEY : v.kind.to_s }
    else
      results.collection&.map(&:decorate)
    end
  end

  def season_page?
    !recommendations? &&
      h.params[:season].present? &&
      !!h.params[:season].match(/^([a-z]+_\d+,?)+$/)
  end

  def recommendations?
    h.params[:controller] == 'recommendations'
  end

  def cache?
    !recommendations?
  end

  def cache_key # rubocop:disable AbcSize
    user_key = user if h.params[:mylist]

    if h.params[:search] || h.params[:q]
      last_created_at = klass
        .select('max(created_at) as created_at')
        .to_a
        .first
        .created_at
    end
    initial_key = [klass.name, user_key, last_created_at, CACHE_VERSION.to_s]

    h.url_params
      .except(:action, :controller, :format)
      .sort_by(&:first)
      .inject(initial_key) { |memo, (k, v)| memo.push "#{k}:#{v}" }
      .compact
  end

  def cache_expires_in
    if h.params[:search] || h.params[:q]
      1.hour
    elsif h.params[:season] || h.params[:status]
      1.day
    else
      3.days
    end
  end

  def prev_page_url
    if page == 2
      h.current_url(page: nil)
    elsif page && page > 1
      h.current_url(page: page - 1)
    end
  end

  def next_page_url
    h.current_url(page: page + 1) if pages_count && page && page < pages_count
  end

  def compiled_filters
    h.params.to_unsafe_h.symbolize_keys.merge(
      order: Animes::SortField.new(DEFAULT_ORDER, h).field,
      censored: true
    )
  end

  def anime?
    @klass == Anime
  end

private

  def anime_ova_ona? db_entry
    db_entry.anime? && (db_entry.kind_ova? || db_entry.kind_ona?)
  end

  def results
    if cache?
      Rails.cache.fetch(*cache_params) { fetch }
    else
      fetch
    end
  end

  def fetch
    if recommendations?
      recommendations_query
    elsif season_page?
      season_query
    else
      page_query
    end
  end

  def cache_params
    [cache_key, expires_in: cache_expires_in]
  end

  def recommendations_query
    ranked_ids = recommend_ranked_ids

    if ranked_ids
      AnimesCollection::RecommendationsQuery.call(
        klass: klass,
        filters: compiled_filters,
        user: user,
        limit: PAGE_LIMIT,
        ranked_ids: ranked_ids
      )
    else
      AnimesCollection::NoPage.new
    end
  end

  def season_query
    AnimesCollection::SeasonQuery.call(
      klass: klass,
      filters: compiled_filters,
      user: user,
      limit: SEASON_LIMIT
    )
  end

  def page_query
    AnimesCollection::PageQuery.call(
      klass: klass,
      filters: compiled_filters,
      user: user,
      limit: PAGE_LIMIT
    )
  end

  def recommend_ranked_ids
    Recommendations::Fetcher.call(
      user: user&.decorated? ? user.object : user,
      klass: klass,
      metric: h.params[:metric],
      threshold: h.params[:threshold].to_i
    )
  end
end
