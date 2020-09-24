class AnimesCollectionController < ShikimoriController # rubocop:disable ClassLength
  CENSORED = /\b(?:sex|секс|porno?|порно)\b/mix

  before_action do
    klass = params[:klass].classify.constantize

    @view = AnimesCollection::View.new klass, current_user
    @menu = Menus::CollectionMenu.new @view.klass
  end

  def index # rubocop:disable all
    model = prepare_model

    censored_search_check
    forbidden_params_redirect_check
    genres_redirect_check model[:genre]
    guest_mylist_check
    one_found_redirect_check
    publishers_redirect_check model[:publisher]
    studios_redirect_check model[:studio]

    og noindex: true, nofollow: true if noindex?

    unless @view.recommendations?
      og page_title: t('page', page: @view.page) if @view.page > 1
      og page_title: collection_title(model).title

      og notice: build_page_notice(model)
      og description: i18n_t("description.#{@view.klass.name.downcase}")
    end

    og description: '', notice: '' if @view.page > 1 && !turbolinks_request?

    og keywords: Titles::AnimeKeywords.new(
      klass: @view.klass,
      season: params[:season],
      kind: params[:kind],
      genres: model[:genre],
      studios: model[:studio],
      publishers: model[:publisher]
    ).keywords

    verify_age_restricted! @view.results.collection
    verify_age_restricted! model[:genre]
    if censored_forbidden? && params[:rating]&.split(',')&.include?(Anime::ADULT_RATING.to_s)
      raise AgeRestricted
    end
  end

  def autocomplete
    scope = @view.klass == Manga ? Manga.where.not(kind: Ranobe::KIND) : @view.klass.all
    scope.where! is_censored: false if params[:censored] == 'false'

    @collection = "Autocomplete::#{@view.klass.name}".constantize
      .call(
        scope: scope,
        phrase: params[:search] || params[:q]
      )
      .map(&:decorate)
  end

  def autocomplete_v2
    og noindex: true, nofollow: true

    autocomplete
    @collection = @collection.map(&:decorate)
  end

private

  def prepare_model
    model = {}

    %i[genre studio publisher].each do |kind|
      next unless params[kind]

      terms = Animes::Filters::Terms.new(
        params[kind],
        "Animes::Filters::By#{kind.to_s.classify}::DRY_TYPE".constantize
      )
      model[kind] = terms
        .positives
        .map { |term| @menu.send(kind.to_s.pluralize).find { |v| v.id == term } }
        .compact
    end

    model
  end

  def genres_redirect_check genres
    return unless params.include?(:genre) && !params[:genre].include?('!')

    ensure_redirect! current_url(genre: genres.map(&:to_param).sort.join(','))
  end

  def studios_redirect_check studios
    return unless params.include?(:studio) && !params[:studio].include?('!')

    ensure_redirect! current_url(studio: studios.map(&:to_param).sort.join(','))
  end

  def publishers_redirect_check publishers
    return unless params.include?(:publisher) && !params[:publisher].include?('!')

    ensure_redirect! current_url(publisher: publishers.map(&:to_param).sort.join(','))
  end

  def guest_mylist_check
    return unless !user_signed_in? && params.include?(:mylist)

    raise ForceRedirect, current_url(mylist: nil)
  end

  def forbidden_params_redirect_check
    if params[:order] == AnimesCollection::View::DEFAULT_ORDER.to_s
      raise ForceRedirect, current_url(order: nil)
    end
  end

  def censored_search_check
    if params[:search] && params[:search] =~ CENSORED && censored_forbidden?
      raise AgeRestricted
    end
  end

  def one_found_redirect_check
    if params[:search].present? && @view.collection.is_a?(Array) &&
        @view.collection.count == 1 && @view.page == 1 && !json?
      raise ForceRedirect, url_for(@view.collection.first)
    end
  end

  def build_page_notice model
    title = collection_title(model).title false

    if collection_title(model).manga_conjugation_variant?
      i18n_t 'notice.manga',
        title: title,
        order_name: order_name
    else
      i18n_t 'notice.non_manga',
        title: title,
        order_name: order_name
    end
  end

  def order_name
    case params[:order]
      when 'name'
        i18n_t 'order.in_alphabetical_order'
      when 'popularity'
        i18n_t 'order.by_popularity'
      when 'released_on', 'aired_on'
        i18n_t 'order.by_released_date'
      when 'id_desc', 'id'
        i18n_t 'order.by_add_date'
      when 'ranked'
        i18n_t 'order.by_ranking'
      else
        i18n_t 'order.by_ranking'
    end
  end

  def collection_title model
    @collection_title ||= Titles::CollectionTitle.new(
      klass: @view.klass,
      user: current_user,
      season: params[:season],
      kind: params[:kind],
      status: params[:status],
      genres: model[:genre],
      studios: model[:studio],
      publishers: model[:publisher]
    )
  end

  def noindex?
    params[:rel] ||
      request.url.include?('order') ||
      @view.collection.empty? ||
      params[:search] ||
      request.url.include?('!')
      # og.description.blank? ||
  end
end
