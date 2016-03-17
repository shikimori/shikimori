# TODO: отрефакторить толстый контроллер
class AnimesCollectionController < ShikimoriController
  helper_method :klass, :entries_per_page
  caches_action :index, :menu, CacheHelper.cache_settings
  before_action :set_order

  # страница каталога аниме/манги
  def index
    mylist_redirect_check
    build_background

    unless shikimori?
      params[:is_adult] = AnimeOnlineDomain::adult_host?(request)
      params[:with_censored] = params[:is_adult]
    end

    query = AniMangaQuery.new(klass, params, current_user).fetch

    if params[:search]
      noindex && nofollow
      raise AgeRestricted if params[:search] =~ /\b(?:sex|секс|porno?|порно)\b/ && censored_forbidden?
      page_title i18n_t('search', search: SearchHelper.unescape(params[:search]))
    end

    # для сезонов без пагинации
    @entries = if params[:season].present? && params[:season] =~ /^([a-z]+_\d+,?)+$/ && !params[:ids_with_sort].present?
      @render_by_kind = true
      fetch_wo_pagination query
    else
      fetch_with_pagination query
    end
    one_found_redirect_check

    if params[:rel] || request.url.include?('order') ||
        @description.blank? || @entries.empty? ||
        params.any? {|k,v| k != 'genre' && v.kind_of?(String) && v.include?(',') }
      noindex and nofollow
    end

    @description = '' if params_page > 1 && !turbolinks_request?
    @title_notice = "" if params_page > 1 && !turbolinks_request?

    description @description
    keywords Titles::AnimeKeywords.new(
      klass: klass,
      season: params[:season],
      type: params[:type],
      genres: @entry_data[:genre],
      studios: @entry_data[:studio],
      publishers: @entry_data[:publisher]
    ).keywords

    raise AgeRestricted if @entry_data[:genre] && @entry_data[:genre].any?(&:censored?) && censored_forbidden?
    raise AgeRestricted if params[:rating] && params[:rating].split(',').include?(Anime::ADULT_RATING) && censored_forbidden?

  rescue BadStatusError
    redirect_to send(collection_url_method, url_params(status: nil)), status: 301

  rescue BadSeasonError
    redirect_to send(collection_url_method, url_params(season: nil)), status: 301

  rescue ForceRedirect => e
    redirect_to e.url, status: 301
  end

  # меню каталога аниме/манги
  def menu
    @menu = Menus::CollectionMenu.new klass
  end

private

  # класс текущего элемента
  def klass
    @klass ||= Object.const_get(params[:klass].to_s.camelize)
  end

  # окружение страниц
  def build_background
    @current_page = params_page
    @menu = Menus::CollectionMenu.new klass

    all_data = {
      genre: @menu.genres,
      publisher: @menu.publishers,
      studio: @menu.studios
    }
    @entry_data = {}

    if params[:type] =~ /[A-Z -]/
      raise ForceRedirect, collection_url(type: params[:type].downcase.sub(/ |-/, '_'))
    end
    [:genre, :studio, :publisher].each do |kind|
      if params[kind]
        all_param_ids = params[kind].split(',').map { |v| v.sub(/^!/, '').to_i }
        included_param_ids = params[kind].split(',').map(&:to_i).select {|v| v > 0 }

        all_entry_data = all_data[kind].select { |v| all_param_ids.include?(v.id) }
        @entry_data[kind] = all_data[kind].select { |v| included_param_ids.include?(v.id) }

        filter_klass = kind.to_s.capitalize.constantize
        all_param_ids.each do |id|
          if filter_klass::Merged.include? id
            raise ForceRedirect, collection_url(kind.to_sym => params[kind].gsub(%r{\b#{id}\b}, filter_klass::Merged[id].to_s))
          end
        end

        next unless all_param_ids.size == 1 && params[kind].sub(/^!/, '') != all_entry_data.first.to_param
        raise ForceRedirect, collection_url(kind.to_sym => all_entry_data.first.to_param)
      end
    end

    if params[:controller] == 'animes_collection'
      page_title build_page_title(@entry_data)
      @title_notice = build_page_description @entry_data
      @description = @page_title.last
    end
  end

  # постраничное разбитие коллекции
  def build_pagination_links(entries, total_pages)
    options = filtered_params

    if total_pages
      @total_pages = total_pages == 0 ? 1 : total_pages
    else
      @total_pages = entries.total_pages == 0 ? 1 : entries.total_pages
    end
    if @current_page == 1
      @prev_page = ''
    else
      @prev_page = url_for(options.merge(page: @current_page == 2 ? nil : (@current_page-1)))
    end

    if @current_page == @total_pages
      @next_page = ''
    else
      @next_page = @current_page < @total_pages ? url_for(options.merge(page: @current_page+1)) : ''
    end
  end

  # редирект для не автороизованных пользователей при ссылках на mylist, чтобы не падало с ошибкой
  def mylist_redirect_check
    if params.include?(:mylist) && !user_signed_in?
      raise ForceRedirect, url_for(filtered_params.merge(mylist: nil))
    end
  end

  # выборка из датасорса без пагинации
  def fetch_wo_pagination(query)
    entries = AniMangaQuery.new(klass, params).order(query)

    ApplyRatedEntries.new(current_user).call(entries)
      .group_by { |v| v.anime? && (v.kind_ova? || v.kind_ona?) ? 'OVA/ONA' : v.kind }
  end

  # выборка из датасорса с пагинацией
  def fetch_with_pagination(ds)
    entries = []
    # выборка id элементов с разбивкой по страницам
    unless params.include? :ids_with_sort
      entries = ds
        .select("#{klass.name.tableize}.id")
        .paginate(page: @current_page, per_page: entries_per_page)
      total_pages = entries.total_pages
    else
      entries = ds
        .where(id: params[:ids_with_sort].keys)
        .where("#{klass.name.tableize}.kind not in (?)", [:special, :music])
        .select("#{klass.name.tableize}.id")
        .to_a
      total_pages = (entries.size * 1.0 / entries_per_page).ceil
      entries = entries
        .sort_by {|v| -params[:ids_with_sort][v.id] }
        .drop(entries_per_page*(@current_page-1))
        .take(entries_per_page)
    end

    entries = klass
      .where(id: entries.map(&:id))
      .includes(:genres)
      .includes(klass == Anime ? :studios : :publishers)

    # повторная сортировка полученной выборки
    if params[:ids_with_sort].present?
      entries = entries.sort_by {|v| -params[:ids_with_sort][v.id] }
    else
      entries = AniMangaQuery.new(klass, params).order(entries).to_a
    end
    build_pagination_links entries, total_pages

    ApplyRatedEntries.new(current_user).call(entries)
  end

  # был ли запущен поиск, и найден ли при этом один элемент
  def one_found_redirect_check
    if params[:search] && @entries.kind_of?(Array) &&
        @entries.count == 1 && @current_page == 1 && !json?
      raise ForceRedirect, url_for(@entries.first)
    end
  end

  def params_page
    [(params[:page] || 1).to_i, 1].max
  end

  def build_page_title entry_data
    collection_title(entry_data).title
  end

  def build_page_description entry_data
    title = collection_title(entry_data).title false

    if collection_title(entry_data).manga_conjugation_variant?
      i18n_t 'description.manga_variant',
        title: title, order_name: order_name
    else
      i18n_t 'description.non_manga_variant',
        title: title, order_name: order_name
    end
  end

  # число аниме/манги на странице
  def entries_per_page
    #user_signed_in? ? 24 : 12
    #user_signed_in? ? 40 : 20
    20
  end

  def filtered_params
    params.merge(
      format: nil,
      exclude_ids: nil,
      ids_with_sort: nil,
      template: nil,
      is_adult: nil,
      exclude_ai_genres: nil
    )
  end

  def collection_url changed_params
    send collection_url_method, filtered_params.merge(changed_params).symbolize_keys
  end

  def collection_url_method
    "#{klass.table_name}_url"
  end

  # TODO: удалить released_at после 01.05.2014
  def order_name
    case params[:order]
      when 'name'
        i18n_t 'order.in_alphabetical_order'
      when 'popularity'
        i18n_t 'order.by_popularity'
      when 'ranked'
        i18n_t 'order.by_ranking'
      when 'released_on', 'released_at', 'aired_on'
        i18n_t 'order.by_released_date'
      when 'id'
        i18n_t 'order.by_add_date'
    end
  end

  def collection_title entry_data
    @collection_title ||= Titles::CollectionTitle.new(
      klass: klass,
      user: current_user,
      season: params[:season],
      type: params[:type],
      status: params[:status],
      genres: entry_data[:genre],
      studios: entry_data[:studio],
      publishers: entry_data[:publisher]
    )
  end

  def set_order
    params[:order] = Animes::SortField.new('ranked', view_context).field
  end
end
