# TODO: refactor to view objects
class AnimesCollectionController < ShikimoriController
  CENSORED = /\b(?:sex|секс|porno?|порно)\b/mix

  before_action do
    klass = params[:klass].classify.constantize

    @view = AnimesCollection::View.new klass, current_user
    @menu = Menus::CollectionMenu.new @view.klass
  end

  def index
    forbidden_params_redirect_check
    @model = prepare_model # should be placed after is_adult check

    if params[:search] || request.url.include?('!')
      og noindex: true, nofollow: true
    end

    censored_search_check
    one_found_redirect_check

    if params[:rel] || request.url.include?('order') ||
        og.description.blank? || @view.collection.empty? ||
        params
          .to_unsafe_h
          .any? { |k, v| k != 'genre' && v.is_a?(String) && v.include?(',') }
      og noindex: true, nofollow: true
    end

    unless @view.recommendations?
      og page_title: t('page', page: @view.page) if @view.page > 1
      og page_title: collection_title(@model).title

      og notice: build_page_notice(@model)
      og description: i18n_t("description.#{@view.klass.name.downcase}")
    end

    og description: '', notice: '' if @view.page > 1 && !turbolinks_request?

    og keywords: Titles::AnimeKeywords.new(
      klass: @view.klass,
      season: params[:season],
      kind: params[:kind],
      genres: @model[:genre],
      studios: @model[:studio],
      publishers: @model[:publisher]
    ).keywords

    if @model[:genre]&.any?(&:censored?) && censored_forbidden?
      raise AgeRestricted
    end
    if params[:rating]&.split(',')&.include?(Anime::ADULT_RATING.to_s) &&
        censored_forbidden?
      raise AgeRestricted
    end
  end

  def autocomplete
    scope = @view.klass == Manga ? Manga.where.not(kind: Ranobe::KIND) : @view.klass.all
    scope.where! is_censored: false if params[:censored] == 'false'

    @collection = "Autocomplete::#{@view.klass.name}".constantize.call(
      scope: scope,
      phrase: params[:search] || params[:q]
    )
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
        .sort
        .map { |term| @menu.send(kind.to_s.pluralize).find { |v| v.id == term } }

      if terms.negatives.none?
        ensure_redirect! current_url(kind => model[kind].map(&:to_param).join(','))
      end
    end

    model
  end

  def forbidden_params_redirect_check
    # if params.include?(:mylist) && !user_signed_in?
    #   raise ForceRedirect, current_url(mylist: nil)
    # end

    if params.include?(:duration) && @view.klass != Anime
      raise ForceRedirect, current_url(duration: nil)
    end

    # if params[:status]&.include? 'planned'
    #   raise(
    #     ForceRedirect,
    #     current_url(status: params['status'].gsub('planned', 'anons'))
    #   )
    # end

    if params[:page] == '0' || params[:page] == '1'
      raise ForceRedirect, current_url(page: nil)
    end

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
      when 'id'
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
end
