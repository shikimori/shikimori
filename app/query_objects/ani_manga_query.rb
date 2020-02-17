# TODO: refactor to bunch of simplier query objects
class AniMangaQuery
  IDS_KEY = :ids
  EXCLUDE_IDS_KEY = :exclude_ids

  DEFAULT_ORDER = 'ranked'

  def initialize klass, params, user = nil
    @params = params

    @klass = klass
    @query = klass.all

    @kind = params[:kind] || ''

    @genre = params[:genre]
    @studio = params[:studio]
    @publisher = params[:publisher]

    @rating = params[:rating]
    @score = params[:score]
    @duration = params[:duration]
    @season = params[:season]
    @status = params[:status]
    @franchise = params[:franchise]
    @achievement = params[:achievement]

    @mylist = params[:mylist]

    @search = params[:search] || params[:q] || params[:phrase]

    @ids = params[IDS_KEY]
    @exclude_ids = params[EXCLUDE_IDS_KEY]

    @user = user

    # TODO: remove all after ||
    @order = params[:order] || (@search_phrase.blank? ? DEFAULT_ORDER : nil)
  end

  def fetch
    Animes::Query.fetch(
      scope: @query,
      params: {
        achievement: @achievement,
        duration: @duration,
        exclude_ids: @exclude_ids,
        franchise: @franchise,
        genre: @genre,
        ids: @ids,
        kind: @kind,
        mylist: @mylist,
        publisher: @publisher,
        rating: @rating,
        score: @score,
        search: @search,
        season: @seasor,
        status: @status,
        studio: @studio,
        order: @order
      },
      user: @user
    )
  end

private

  def mylist?
    @mylist.present? && @mylist !~ /^(!\w+,?)+$/
  end

  def userlist?
    !!@params[:userlist]
  end

  def do_not_censore?
    [false, 'false'].include?(@params[:censored]) ||
      mylist? || userlist? ||
      @franchise.present? ||
      @achievement.present? ||
      @studio.present? ||
      @ids.present?
  end

  def censored!
    if @genre
      genres = bang_split(@genre.split(','), true).each { |_k, v| v.flatten! }
    end
    ratings = bang_split @rating.split(',') if @rating

    rx = ratings && ratings[:include].include?(Anime::ADULT_RATING.to_s)
    hentai = genres && (genres[:include] & Genre::HENTAI_IDS).any?
    yaoi = genres && (genres[:include] & Genre::YAOI_IDS).any?
    yuri = genres && (genres[:include] & Genre::YURI_IDS).any?

    return if do_not_censore?
    return if rx || hentai || yaoi || yuri
    return if @publisher || @studio

    if @params[:censored] == true || @params[:censored] == 'true'
      @query = @query.where(is_censored: false)
    end
  end

  # отключение выборки по музыке
  def disable_music!
    unless @kind.match?(/music/) || do_not_censore?
      @query = @query.where("#{table_name}.kind != ?", :music)
    end
  end

  # сортировка по параметрам запроса
  def params_order query
    query.order self.class.order_sql(@order, @klass)
  end

  # имя таблицы аниме
  def table_name
    @klass.table_name
  end

  # разбитие на 2 группы по наличию !, плюс возможная обработка элементов
  def bang_split values, force_integer = false
    data = values.each_with_object(include: [], exclude: []) do |v, memo|
      memo[v.starts_with?('!') ? :exclude : :include] << v.sub('!', '')
    end

    if force_integer
      data[:include].map!(&:to_i)
      data[:exclude].map!(&:to_i)
    end

    if block_given?
      data[:include].map! { |v| yield v }
      data[:exclude].map! { |v| yield v }
    end

    data
  end
end
