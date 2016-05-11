# TODO: отрефакторить толстый контроллер
class AnimesCollectionController < ShikimoriController
  CENSORED = /\b(?:sex|секс|porno?|порно)\b/mix

  before_action do
    params[:order] = Animes::SortField.new('ranked', view_context).field

    @view = AnimesCollection::View.new params[:klass].classify.constantize
    @menu = Menus::CollectionMenu.new @view.klass
  end

  # страница каталога аниме/манги
  def index
    mylist_redirect_check
    build_background

    unless shikimori?
      params[:is_adult] = AnimeOnlineDomain::adult_host?(request)
      params[:with_censored] = params[:is_adult]
    end

    if params[:search]
      noindex && nofollow
      raise AgeRestricted if params[:search] =~ CENSORED && censored_forbidden?
      page_title i18n_t('search', search: SearchHelper.unescape(params[:search]))
    end

    one_found_redirect_check

    if params[:rel] || request.url.include?('order') ||
        @description.blank? || @view.collection.empty? ||
        params.any? {|k,v| k != 'genre' && v.kind_of?(String) && v.include?(',') }
      noindex and nofollow
    end

    @description = '' if @view.page > 1 && !turbolinks_request?
    @title_notice = '' if @view.page > 1 && !turbolinks_request?

    description @description
    keywords Titles::AnimeKeywords.new(
      klass: @view.klass,
      season: params[:season],
      type: params[:type],
      genres: @entry_data[:genre],
      studios: @entry_data[:studio],
      publishers: @entry_data[:publisher]
    ).keywords

    raise AgeRestricted if @entry_data[:genre] && @entry_data[:genre].any?(&:censored?) && censored_forbidden?
    raise AgeRestricted if params[:rating] && params[:rating].split(',').include?(Anime::ADULT_RATING) && censored_forbidden?

  rescue BadStatusError
    redirect_to @view.url(status: nil), status: 301
  rescue BadSeasonError
    redirect_to @view.url(season: nil), status: 301
  rescue ForceRedirect => e
    redirect_to e.url, status: 301
  end

private

  # TODO: refactor this shit
  def build_background
    all_data = {
      genre: @menu.genres,
      publisher: @menu.publishers,
      studio: @menu.studios
    }
    @entry_data = {}

    if params[:type] =~ /[A-Z -]/
      raise ForceRedirect, @view.url(type: params[:type].downcase.sub(/ |-/, '_'))
    end
    types = [@view.klass.kind.values + %w(tv_48 tv_24 tv_13)].join '|'
    if params[:type] && params[:type] !~ %r{\A (?: !? (?:#{types}) (?:,|\Z ) )+ \Z}mix
      fixed = params[:type].split(',').select {|v| v =~ %r{\A !? (?:#{types}) \Z }mix }
      raise ForceRedirect, @view.url(type: fixed.join(','))
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
            fixed_kind = params[kind].gsub(%r{\b#{id}\b}, filter_klass::Merged[id].to_s)
            raise ForceRedirect, @view.url(kind.to_sym => fixed_kind)
          end
        end

        next unless all_param_ids.size == 1 && params[kind].sub(/^!/, '') != all_entry_data.first.to_param
        raise ForceRedirect, @view.url(kind.to_sym => all_entry_data.first.to_param)
      end
    end

    unless @view.recommendations?
      page_title collection_title(@entry_data).title
      @title_notice = build_page_description @entry_data
      @description = @page_title.last
    end
  end

  # редирект для не автороизованных пользователей при ссылках на mylist, чтобы не падало с ошибкой
  def mylist_redirect_check
    if params.include?(:mylist) && !user_signed_in?
      raise ForceRedirect, @view.url(mylist: nil)
    end
  end

  # был ли запущен поиск, и найден ли при этом один элемент
  def one_found_redirect_check
    if params[:search] && @view.collection.kind_of?(Array) &&
        @view.collection.count == 1 && @view.page == 1 && !json?
      raise ForceRedirect, url_for(@view.collection.first)
    end
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

  def order_name
    case params[:order]
      when 'name'
        i18n_t 'order.in_alphabetical_order'
      when 'popularity'
        i18n_t 'order.by_popularity'
      when 'ranked'
        i18n_t 'order.by_ranking'
      when 'released_on', 'aired_on'
        i18n_t 'order.by_released_date'
      when 'id'
        i18n_t 'order.by_add_date'
    end
  end

  def collection_title entry_data
    @collection_title ||= Titles::CollectionTitle.new(
      klass: @view.klass,
      user: current_user,
      season: params[:season],
      type: params[:type],
      status: params[:status],
      genres: entry_data[:genre],
      studios: entry_data[:studio],
      publishers: entry_data[:publisher]
    )
  end
end
