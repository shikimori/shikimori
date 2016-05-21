class AnimesCollection::View < ViewObjectBase
  vattr_initialize :klass, :user

  instance_cache :collection, :results, :filtered_params
  delegate :page, :pages_count, to: :results

  def collection
    if season_page?
      results.collection.each_with_object({}) do |(key, entries), memo|
        memo[key] = entries.map(&:decorate)
      end
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

  def cache_key
    user_key = user if h.params[:mylist]

    h.params
      .except(:format, :controller, :action)
      .sort_by(&:first)
      .inject([klass.name, user_key]) { |memo, (k, v)| memo.push "#{k}:#{v}" }
      .compact
  end

  def cache_expires_in
    h.params[:season] || h.params[:status] ? 1.day : 1.week
  end

  def url changed_params
    if recommendations?
      h.recommendations_url filtered_params.merge(changed_params)
    else
      h.animes_url filtered_params.merge(changed_params)
    end
  end

  def prev_page_url
    url(page: page - 1) if page > 1
  end

  def next_page_url
    url(page: page + 1) if page < pages_count
  end

  def filtered_params
    h.params.except(
      :format, :template, :is_adult, :controller, :action,
      AnimesCollection::RecommendationsQuery::IDS_KEY,
      AnimesCollection::RecommendationsQuery::EXCLUDE_IDS_KEY
    )
  end

private

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
    [[*cache_key, :v2], expires_in: cache_expires_in]
  end

  def recommendations_query
    AnimesCollection::RecommendationsQuery.new(klass, h.params, user).fetch
  end

  def season_query
    AnimesCollection::SeasonQuery.new(klass, h.params, user).fetch
  end

  def page_query
    AnimesCollection::PageQuery.new(klass, h.params, user).fetch
  end
end
