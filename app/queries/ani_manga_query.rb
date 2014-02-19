class AniMangaQuery
  include CompleteQuery

  AnimeFeatured = [7724,5081,6746,7,4224,2418,3958,849,2562,1698,2025,2251,1601,5909,3549,396,5630,2966,957,4177,1606,1559,102,240,3358,877,5781,7054,3655,245,3702,4898,2926,4081,4066,5530,3974,6408,1575,5114,5680,9253]
  AnimeSerials = [1604,6702,6033,235,21,1735,170,738,1482,820,15,2076,249,22,45,627,269,28]

  Ratings = {
    'G' => ['G - All Ages'],
    'PG' => ['PG - Children'],
    'PG-13' => ['PG-13 - Teens 13 or older'],
    'R' => ['R+ - Mild Nudity'],
    'NC-17' => ['R - 17+ (violence & profanity)', 'R - 17+ (violence &amp; profanity)', 'Rx - Hentai'],
  }
  Durations = {
    'S' => "(duration >= 0 and duration <= 10)",
    'D' => "(duration > 10 and duration <= 30)",
    'F' => "(duration > 30)"
  }
  DefaultOrder = 'ranked'

  def initialize klass, params, user=nil
    @params = params

    @klass = klass
    @query = @klass

    @type = params[:type] || ''

    @genre = params[:genre]
    @studio = params[:studio]
    @publisher = params[:publisher]

    @rating = params[:rating]
    @duration = params[:duration]
    @season = params[:season]
    @status = params[:status]

    @mylist = params[:mylist]
    @search = SearchHelper.unescape params[:search]

    @exclude_ids = params[:exclude_ids]

    @user = user

    @order = params[:order] || (@search.blank? ? DefaultOrder : nil)
  end

  # выборка аниме или манги по заданным параметрам
  def fetch page = nil, limit = nil
    type!
    censored!
    disable_music!

    associations!

    rating!
    duration!
    season!
    status!

    mylist!

    exclude_ids!
    search!

    paginate! page, limit if page && limit

    order @query
  end

  def complete
    search!
    search_order(@query.limit AutocompleteLimit).reverse
  end

  # сортировка по параметрам
  def order query
    if @search.present? && @order.blank?
      search_order query
    else
      params_order query
    end
  end

private
  def mylist?
    @mylist && @mylist !~ /^(!\w+,?)+$/
  end

  def userlist?
    @params[:controller] == 'user_lists'
  end

  def search?
    @search.present?
  end

  def uncensored?
    @params[:with_censored].present?
  end

  # фильтр по типам
  def type!
    return if @type.blank?

    raw_types = @type.split(',').map do |type|
      with_bang = type.starts_with? '!'

      case type
        when 'TV-13', '!TV-13'
          query = "(kind = 'TV' and episodes != 0 and episodes <= 16) or (kind = 'TV' and episodes = 0 and episodes_aired <= 16)"
          @query = @query.where(with_bang ? "not(#{query})" : query)
          with_bang ? nil : 'TV'

        when 'TV-24', '!TV-24'
          query = "(kind = 'TV' and episodes != 0 and episodes >= 17 and episodes <= 28) or (kind = 'TV' and episodes = 0 and episodes_aired >= 17 and episodes_aired <= 28)"
          @query = @query.where(with_bang ? "not(#{query})" : query)
          with_bang ? nil : 'TV'

        when 'TV-48', '!TV-48'
          query = "(kind = 'TV' and episodes != 0 and episodes >= 29) or (kind = 'TV' and episodes = 0 and episodes_aired >= 29)"
          @query = @query.where(with_bang ? "not(#{query})" : query)
          with_bang ? nil : 'TV'

        else
          type.gsub(/-/, ' ')
      end
    end.compact

    types = bang_split raw_types

    @query = @query.where(kind: types[:include]) if types[:include].any?
    @query = @query.where.not(kind: types[:exclude]) if types[:exclude].any?
  end

  # включение цензуры
  def censored!
    genres = bang_split(@genre.split(','), true).each {|k,v| v.flatten! } if @genre
    hentai = @genre && genres[:include].include?(Genre::HentaiID)
    yaoi = @genre && genres[:include].include?(Genre::YaoiID)

    unless hentai || yaoi || mylist? || userlist? || uncensored? || search? || @publisher || @studio
      @query = @query.where(censored: false)
    end
  end

  # отключение выборки по музыке
  def disable_music!
    unless @type =~ /Music/ || mylist? || userlist?
      @query = @query.where.not(kind: 'Music')
    end
  end

  # фильтрация по жанрам, студиям и издателям
  def associations!
    havings = []
    [[Genre, @genre], [Studio, @studio], [Publisher, @publisher]].each do |association_klass, values|
      next if values.blank?

      ids = bang_split(values.split(','), true) {|v| association_klass.related(v.to_i) }
      joined_filter(ids, association_klass.table_name)

      ids[:include].each do |ids|
        havings << "sum(case #{association_klass.table_name}.id %s else 0 end) > 0" % [ids.map {|v| "when #{v} then 1" }.join(' ')]
      end if ids[:include].any?
    end
    # группировка при необходимости
    @query = @query.group("#{@klass.table_name}.id").having(havings.join ' and ') if havings.any?
  end

  # фильтрация по рейнтингу
  def rating!
    return if @rating.blank?
    ratings = bang_split @rating.split(',')

    if ratings[:include].any?
      includes = ratings[:include].map {|rating| Ratings[rating] }.flatten
      @query = @query.where(rating: includes)
    end
    if ratings[:exclude].any?
      excludes = ratings[:exclude].map {|rating| Ratings[rating] }.flatten
      @query = @query.where.not(rating: excludes)
    end
  end

  # фильтрация по длительности эпизода
  def duration!
    return if @duration.blank?
    durations = bang_split(@duration.split(','))

    @query = @query.where durations[:include].map {|duration| Durations[duration] }.join(' or ') if durations[:include].any?
    @query = @query.where "not (#{durations[:exclude].map {|duration| Durations[duration] }.join(' or ')})" if durations[:exclude].any?
  end

  # фильтрация по сезонам
  def season!
    return if @season.blank?
    seasons = bang_split(@season.split(','))

    query = seasons[:include].map {|v| AniMangaSeason.query_for(v, @klass) }
    @query = @query.where(query.join(" OR ")) unless query.empty?

    query = seasons[:exclude].map {|v| "NOT (#{AniMangaSeason.query_for(v, @klass)})" }
    @query = @query.where(query.join(" AND ")) unless query.empty?
  end

  # фильтрация по статусам
  def status!
    return if @status.blank?
    statuss = bang_split(@status.split(','))

    query = statuss[:include].map {|v| AniMangaStatus.query_for(v, @klass) }
    @query = @query.where(query.join(" OR ")) unless query.empty?

    query = statuss[:exclude].map {|v| "NOT (#{AniMangaStatus.query_for(v, @klass)})" }
    @query = @query.where(query.join(" AND ")) unless query.empty?
  end

  # фильтрация по наличию в собственном списке
  def mylist!
    return if @mylist.blank?
    statuses = bang_split(@mylist.split(','), true)

    animelist = @user.send("#{@klass.name.downcase}_rates")
          .includes(@klass.name.downcase.to_sym)
          .inject(:include => [], :exclude => []) do |result, v|
      result[:include] << v.target_id if statuses[:include].include?(v.status)
      result[:exclude] << v.target_id if statuses[:exclude].include?(v.status)
      result
    end

    @query = @query.where(id: animelist[:include]) if animelist[:include].any?
    @query = @query.where.not(id: animelist[:exclude]) if animelist[:exclude].any?
  end

  # фильтрация по id
  def exclude_ids!
    if @exclude_ids.present?
      ids = @exclude_ids.map(&:to_i)
      @query = @query.where.not(id: ids)
    end
  end

  # поиск по названию
  def search!
    return if @search.blank?

    @query = @query.where(search_queries.join(' or '))
  end

  # пагинация
  def paginate! page, limit
    @query = @query
      .offset(limit * (page-1))
      .limit(limit + 1)
  end

  # варианты, которые будем перебирать при поиске
  def search_queries
    search_fields(@search).map {|field| field_search_query field }.flatten.compact
  end

  # поля, по которым будет осузествлён поиск
  def search_fields term
    if term.contains_cjkv?
      [:japanese]
    else
      [:name, :russian, :synonyms, :english]
    end
  end

  def field_search_query field
    term = @search
    pterm = @search.gsub(' ', '% ')
    queries = []

    if field == :japanese || field == :english || field == :synonyms
      queries << [
        "#{table_name}.#{field} like #{Entry.sanitize "% #{term}%"}",
        "#{table_name}.#{field} like #{Entry.sanitize "%#{term}%"}"
      ]
      if field == :japanese
        queries << "#{table_name}.#{field} like #{Entry.sanitize "%#{term.to_yaml.gsub(/^--- !binary \|\n|\n\n$/, '')}%"}"
      end

    else
      queries = [
        "#{table_name}.#{field} = #{Entry.sanitize term}",
        "#{table_name}.#{field} like #{Entry.sanitize "#{term}%"}",
        "#{table_name}.#{field} like #{Entry.sanitize term.gsub(/([A-zА-я0-9])/, '\1% ').sub(/ $/, '')}"
      ]

      if field == :english || field == :synonyms || field == :name
        queries << "#{table_name}.#{field} like #{Entry.sanitize term.broken_translit}"
        queries << "#{table_name}.#{field} like #{Entry.sanitize "% #{term}%"}"
        queries << "#{table_name}.#{field} like #{Entry.sanitize "% _#{term}%"}"
        queries << "#{table_name}.#{field} like #{Entry.sanitize "% #{term}%"}"
        queries << "#{table_name}.#{field} like #{Entry.sanitize "%#{term}%"}"

        if term != pterm
          queries << "#{table_name}.#{field} like #{Entry.sanitize "#{pterm.broken_translit}%"}"
        end
      end

      unless term.eql? pterm
        queries << "#{table_name}.#{field} like #{Entry.sanitize "#{pterm}%"}"
      end
    end

    queries
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
  def bang_split values, force_integer=false
    data = values.inject(:include => [], :exclude => []) do |rez,v|
      rez[v.starts_with?('!') ? :exclude : :include] << v.sub('!', '')
      rez
    end

    if force_integer
      data[:include].map!(&:to_i)
      data[:exclude].map!(&:to_i)
    end

    if block_given?
      data[:include].map! {|v| yield(v) }
      data[:exclude].map! {|v| yield(v) }
    end

    data
  end

  # применение включающего и исключающего фильтра для джойнящейся сущности
  def joined_filter filters, table_name
    if filters[:include].any?
      @query = @query.joins(table_name.to_sym)
          .where(table_name => { id: filters[:include].flatten })
    end

    joined_table = (@klass.table_name+'_'+table_name.to_s).sub('mangas_genres', 'genres_mangas')

    @query = @query.where("#{@klass.table_name}.id not in (
        select distinct(t.#{@klass.name.downcase}_id)
          from #{joined_table} t
            where t.#{table_name.to_s.singularize}_id in (#{filters[:exclude].flatten.join(',')})
      )") if filters[:exclude].any?
  end

  # sql представление сортировки датасорса
  def self.order_sql field, klass
    case field
      when 'name'
        "#{klass.table_name}.name"

      when 'russian'
        "if(#{klass.table_name}.russian is null or #{klass.table_name}.russian='', #{klass.table_name}.name, #{klass.table_name}.russian)"

      when 'episodes'
        "#{klass.table_name}.#{klass == Anime ? 'episodes' : 'chapters'} desc"

      when 'status'
        "if(#{klass.table_name}.status='Not yet aired' or #{klass.table_name}.status='Not yet published', 'AAA', if(#{klass.table_name}.status='Publishing', 'Currently Airing', #{klass.table_name}.status))"

      when 'popularity'
        'if(popularity=0,999999,popularity)'

      when 'ranked'
        'if(ranked=0,999999,ranked)'

      # TODO: удалить released_at и released после 01.05.2014
      when 'released_on', 'released_at', 'released'
        'if(released_on is null, aired_on, released_on) desc'

      when 'aired_on'
        'aired_on desc'

      when 'id'
        "#{klass.table_name}.id desc"

      when 'my', 'rate'
        "user_rates.score desc, #{klass.table_name}.name"

      when 'site_score'
        "#{klass.table_name}.site_score desc"

      when 'kind'
        "#{klass.table_name}.kind"

      when 'user_1', 'user_2' # кастомные сортировки
        nil

      else
        #raise ArgumentError, "unknown order '#{field}'"
        order_sql(AniMangaQuery::DefaultOrder, klass)
    end
  end
end
