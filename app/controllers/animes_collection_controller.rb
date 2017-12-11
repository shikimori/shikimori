# TODO: refactor to view objects
class AnimesCollectionController < ShikimoriController
  CENSORED = /\b(?:sex|секс|porno?|порно)\b/mix

  before_action do
    klass = params[:klass].classify.constantize

    @view = AnimesCollection::View.new klass, current_user
    @menu = Menus::CollectionMenu.new @view.klass
  end

  # страница каталога аниме/манги
  def index
    forbidden_params_redirect_check
    build_background # should be placed after is_adult check

    if params[:search]
      noindex && nofollow
      raise AgeRestricted if params[:search] =~ CENSORED && censored_forbidden?
      page_title i18n_t('search', search: SearchHelper.unescape(params[:search]))
    end

    one_found_redirect_check

    if params[:rel] || request.url.include?('order') ||
        @description.blank? || @view.collection.empty? ||
        params.to_unsafe_h.any? { |k,v| k != 'genre' && v.kind_of?(String) && v.include?(',') }
      noindex and nofollow
    end

    @description = '' if @view.page > 1 && !turbolinks_request?
    @title_notice = '' if @view.page > 1 && !turbolinks_request?

    description @description
    keywords Titles::AnimeKeywords.new(
      klass: @view.klass,
      season: params[:season],
      type: params[:type],
      genres: @model[:genre],
      studios: @model[:studio],
      publishers: @model[:publisher]
    ).keywords

    raise AgeRestricted if @model[:genre] && @model[:genre].any?(&:censored?) && censored_forbidden?
    raise AgeRestricted if params[:rating] && params[:rating].split(',').include?(Anime::ADULT_RATING) && censored_forbidden?
  end

private

  # TODO: refactor this shit
  def build_background
    all_data = {
      genre: @menu.genres,
      publisher: @menu.publishers,
      studio: @menu.studios
    }
    @model = {}

    if params[:type] =~ /[A-Z -]/
      raise ForceRedirect, current_url(type: params[:type].downcase.sub(/ |-/, '_'))
    end
    types = [@view.klass.kind.values + %w(tv_48 tv_24 tv_13)].join '|'
    if params[:type] && params[:type] !~ %r{\A (?: !? (?:#{types}) (?:,|\Z ) )+ \Z}mix
      fixed = params[:type].split(',').select {|v| v =~ %r{\A !? (?:#{types}) \Z }mix }
      raise ForceRedirect, current_url(type: fixed.join(','))
    end

    [:genre, :studio, :publisher].each do |kind|
      if params[kind]
        all_param_ids = params[kind].split(',').map { |v| v.sub(/^!/, '').to_i }
        included_param_ids = params[kind].split(',').map(&:to_i).select {|v| v > 0 }

        all_model = all_data[kind].select { |v| all_param_ids.include?(v.id) }
        @model[kind] = all_data[kind].select { |v| included_param_ids.include?(v.id) }

        filter_klass = kind.to_s.capitalize.constantize
        all_param_ids.each do |id|
          if filter_klass::Merged.include? id
            fixed_kind = params[kind].gsub(%r{\b#{id}\b}, filter_klass::Merged[id].to_s)
            raise ForceRedirect, current_url(kind.to_sym => fixed_kind)
          end
        end

        next unless all_param_ids.size == 1 && params[kind].sub(/^!/, '') != all_model.first.to_param
        raise ForceRedirect, current_url(kind.to_sym => all_model.first.to_param)
      end
    end

    unless @view.recommendations?
      page_title t('page', page: @view.page) if @view.page > 1
      page_title collection_title(@model).title

      @title_notice = build_page_description @model
      @description = @page_title.last
    end
  end

  def forbidden_params_redirect_check
    if params.include?(:mylist) && !user_signed_in?
      raise ForceRedirect, current_url(mylist: nil)
    end

    if params.include?(:duration) && @view.klass == Manga
      raise ForceRedirect, current_url(duration: nil)
    end

    if params[:status]&.include? 'planned'
      raise(
        ForceRedirect,
        current_url(status: params['status'].gsub('planned', 'anons'))
      )
    end

    if params[:page] == '0' || params[:page] == '1'
      raise ForceRedirect, current_url(page: nil)
    end

    if params[:order] == AnimesCollection::View::DEFAULT_ORDER
      raise ForceRedirect, current_url(order: nil)
    end
  end

  # был ли запущен поиск, и найден ли при этом один элемент
  def one_found_redirect_check
    if params[:search] && @view.collection.is_a?(Array) &&
        @view.collection.count == 1 && @view.page == 1 && !json?
      raise ForceRedirect, url_for(@view.collection.first)
    end
  end

  def build_page_description model
    title = collection_title(model).title false

    if collection_title(model).manga_conjugation_variant?
      i18n_t 'description.manga_variant',
        title: title, order_name: order_name
    else
      i18n_t 'description.non_manga_variant',
        title: title, order_name: order_name
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
      type: params[:type],
      status: params[:status],
      genres: model[:genre],
      studios: model[:studio],
      publishers: model[:publisher]
    )
  end
end
