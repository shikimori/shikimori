# TODO: refactor to bunch of simplier query objects
class AniMangaQuery
  include CompleteQuery

  EXCLUDE_AI_GENRES_KEY = :exclude_ai_genres

  Durations = {
    'S' => "(duration >= 0 and duration <= 10)",
    'D' => "(duration > 10 and duration <= 30)",
    'F' => "(duration > 30)"
  }
  DEFAULT_ORDER = 'ranked'
  GENRES_EXCLUDED_BY_SEX = {
    'male' => Genre::YAOI_IDS + Genre::SHOUNEN_AI_IDS,
    'female' => Genre::HENTAI_IDS + Genre::SHOUJO_AI_IDS + Genre::YURI_IDS,
    '' => Genre::CENSORED_IDS + Genre::SHOUNEN_AI_IDS + Genre::SHOUJO_AI_IDS
  }

  def initialize klass, params, user=nil
    @params = params

    @klass = klass
    @query = @klass

    @type = params[:type] || ''

    @genre = params[:genre]
    @studio = params[:studio]
    @publisher = params[:publisher]

    @rating = params[:rating]
    @score = params[:score]
    @duration = params[:duration]
    @season = params[:season]
    @status = params[:status]

    @mylist = params[:mylist]
    @search = SearchHelper.unescape params[:search]

    @exclude_ai_genres = params[EXCLUDE_AI_GENRES_KEY]
    @exclude_ids = params[:exclude_ids]

    @user = user

    #TODO: remove all after ||
    @order = params[:order] || (@search.blank? ? DEFAULT_ORDER : nil)
  end

  # выборка аниме или манги по заданным параметрам
  def fetch page = nil, limit = nil
    @query = @query.preload(:genres) # важно! не includes
    @query = @query.preload(@klass == Anime ? :studios : :publishers) # важно! не includes

    type!
    censored!
    disable_music!

    exclude_ai_genres!
    associations!

    rating!
    score!
    duration!
    season!
    status!

    mylist!

    exclude_ids!
    search!
    video!

    paginate! page, limit if page && limit

    order @query
  end

  def complete
    search!
    censored!
    search_order(@query.limit AUTOCOMPLETE_LIMIT).reverse
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
    !!@params[:userlist]
  end

  def search?
    @search.present?
  end

  def censored?
    @params[:censored] == true
  end

  # фильтр по типам
  def type!
    return if @type.blank?

    types = @type
      .split(',')
      .each_with_object(complex: [], simple: []) do |type, memo|
        memo[type =~ /tv_\d+/ ? :complex : :simple] << type
      end

    simple_types = bang_split types[:simple]

    simple_queries = {
      include: simple_types[:include]
        .delete_if { |v| v == 'tv' && types[:complex].any? { |q| q =~ /^tv_/ } }
        .map do |type|
          "#{@klass.table_name}.kind = #{Anime.sanitize type}"
        end,
      exclude: simple_types[:exclude].map do |type|
        "#{@klass.table_name}.kind = #{Anime.sanitize type}"
      end
    }
    complex_queries = { include: [], exclude: [] }

    types[:complex].each do |type|
      with_bang = type.starts_with? '!'

      query = case type
        when 'tv_13', '!tv_13'
          "(#{@klass.table_name}.kind = 'tv' and episodes != 0 and episodes <= 16) or (#{@klass.table_name}.kind = 'tv' and episodes = 0 and episodes_aired <= 16)"

        when 'tv_24', '!tv_24'
          "(#{@klass.table_name}.kind = 'tv' and episodes != 0 and episodes >= 17 and episodes <= 28) or (#{@klass.table_name}.kind = 'tv' and episodes = 0 and episodes_aired >= 17 and episodes_aired <= 28)"

        when 'tv_48', '!tv_48'
          "(#{@klass.table_name}.kind = 'tv' and episodes != 0 and episodes >= 29) or (#{@klass.table_name}.kind = 'tv' and episodes = 0 and episodes_aired >= 29)"
      end

      complex_queries[with_bang ? :exclude : :include] << query
    end

    includes = (simple_queries[:include] + complex_queries[:include]).compact
    excludes = (simple_queries[:exclude] + complex_queries[:exclude]).compact

    if includes.any?
      @query = @query.where includes.join(' or ')
    end
    if excludes.any?
      @query = @query.where 'not(' + excludes.join(' or ') + ')'
    end
  end

  # включение цензуры
  def censored!
    genres = bang_split(@genre.split(','), true).each {|k,v| v.flatten! } if @genre
    ratings = bang_split @rating.split(',') if @rating

    rx = ratings && ratings[:include].include?(Anime::ADULT_RATING)
    hentai = genres && (genres[:include] & Genre::HENTAI_IDS).any?
    yaoi = genres && (genres[:include] & Genre::YAOI_IDS).any?
    yuri = genres && (genres[:include] & Genre::YURI_IDS).any?

    if censored? || !(
      rx || hentai || yaoi || yuri || mylist? || userlist? || search? ||
      @publisher || @studio
    )
      @query = @query.where(censored: false)
    end
  end

  # отключение выборки по музыке
  def disable_music!
    unless @type =~ /music/ || mylist? || userlist?
      @query = @query.where("#{@klass.table_name}.kind != ?", :music)
    end
  end

  # отключение всего зацензуренной для парней/девушек
  def exclude_ai_genres!
    return unless @exclude_ai_genres && @user

    excludes = GENRES_EXCLUDED_BY_SEX[@user.sex || '']

    @genre = if @genre.present?
      "#{@genre},!#{excludes.join ',!'}"
    else
      "!#{excludes.join ',!'}"
    end
  end

  # фильтрация по жанрам, студиям и издателям
  def associations!
    havings = []
    [[Genre, @genre], [Studio, @studio], [Publisher, @publisher]].each do |association_klass, values|
      next if values.blank? || (@klass == Anime && association_klass == Publisher) || (@klass == Manga && association_klass == Studio)

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
      @query = @query.where(rating: ratings[:include])
    end
    if ratings[:exclude].any?
      @query = @query.where.not(rating: ratings[:exclude])
    end
  end

  # фильтрация по оценке
  def score!
    return if @score.blank?

    @score.split(',').each do |score|
      @query = @query.where("score >= #{score.to_i}")
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

    query = seasons[:include].map {|v| AnimeSeasonQuery.new(v, @klass).to_sql }
    @query = @query.where(query.join(" OR ")) unless query.empty?

    query = seasons[:exclude].map {|v| "NOT (#{AnimeSeasonQuery.new(v, @klass).to_sql})" }
    @query = @query.where(query.join(" AND ")) unless query.empty?
  end

  # фильтрация по статусам
  def status!
    return if @status.blank?
    statuss = bang_split @status.split(',')

    query = statuss[:include].map do |status|
      #AnimeStatusQuery.new(@klass.all).by_status(status).arel.ast.cores.first.wheres.first.to_sql
      AnimeStatusQuery.new(@klass.all).by_status(status).to_sql.sub(/^.* WHERE /, '')
    end
    @query = @query.where query.join(' OR ') unless query.empty?

    query = statuss[:exclude].map do |status|
      'NOT (' +
        AnimeStatusQuery.new(@klass.all).by_status(status).to_sql.sub(/^.* WHERE /, '') +
        #AnimeStatusQuery.new(@klass.all).by_status(status).arel.ast.cores.first.wheres.first.to_sql +
        ')'
    end
    @query = @query.where query.join(' AND ') unless query.empty?
  end

  # фильтрация по наличию в собственном списке
  def mylist!
    return if @mylist.blank? || @user.blank?
    statuses = bang_split(@mylist.split(','), true)

    animelist = @user
      .send("#{@klass.name.downcase}_rates")
      .includes(@klass.name.downcase.to_sym)
      .inject(:include => [], :exclude => []) do |result, v|
        result[:include] << v.target_id if statuses[:include].include?(v[:status])
        result[:exclude] << v.target_id if statuses[:exclude].include?(v[:status])
        result
      end

    animelist[:include] << 0 if statuses[:include].any? && animelist[:include].none?
    animelist[:exclude] << 0 if statuses[:exclude].any? && animelist[:exclude].none?

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

  # фильтрация по наличию видео
  def video!
    return if @params[:with_video].blank?

    @query = @query
      .where('animes.id in (select distinct(anime_id) from anime_videos)')
      .where(@params[:is_adult] ? AnimeVideo::XPLAY_CONDITION : AnimeVideo::PLAY_CONDITION)
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

  # поля, по которым будет осуществлён поиск
  def search_fields term
    if term.contains_cjkv?
      [:japanese]
    else
      [:name, :russian, :synonyms, :english]
    end
  end

  def field_search_query field
    term = @search.gsub(/\\(['"])/, '\1')
    pterm = term.gsub(' ', '% ')
    queries = []

    table_field = transalted_field "#{table_name}.#{field}"

    if field == :japanese || field == :english || field == :synonyms
      queries << [
        "#{table_field} ilike #{Topic.sanitize "% #{term.gsub('*', '%')}%"}",
        "#{table_field} ilike #{Topic.sanitize "%#{term.gsub('*', '%')}%"}"
      ]
      if field == :japanese
        queries << "#{table_field} ilike #{Topic.sanitize "%#{term.to_yaml.gsub(/^--- !binary \|\n|\n\n$/, '').gsub('*', '%')}%"}"
      end

    else
      queries = [
        "#{table_field} = #{Topic.sanitize term}",
        "#{table_field} ilike #{Topic.sanitize "#{term}%"}",
        "#{table_field} ilike #{Topic.sanitize term.gsub(/([A-zА-я0-9])/, '\1% ').sub(/ $/, '')}"
      ]

      if field == :english || field == :synonyms || field == :name || field == :russian
        queries << "#{table_field} ilike #{Topic.sanitize term.broken_translit.gsub(/'/, '')}" if field != :russian
        queries << "#{table_field} ilike #{Topic.sanitize "% #{term}%"}"
        queries << "#{table_field} ilike #{Topic.sanitize "% _#{term}%"}"
        queries << "#{table_field} ilike #{Topic.sanitize "% #{term}%"}"
        queries << "#{table_field} ilike #{Topic.sanitize "%#{term}%"}"

        if term != pterm
          queries << "#{table_field} ilike #{Topic.sanitize "#{pterm.broken_translit.gsub(/'/, '')}%"}"
        end
      end

      unless term.eql? pterm
        queries << "#{table_field} ilike #{Topic.sanitize "#{pterm}%"}"
      end

      if field == :name && term.include?('*')
        queries << "#{table_field} ilike #{Topic.sanitize term.gsub('*', '%')}"
        queries << "#{table_field} ilike #{Topic.sanitize "#{term.gsub '*', '%'}%"}"
        queries << "#{table_field} ilike #{Topic.sanitize "%#{term.gsub '*', '%'}%"}"
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
      data[:include].map! { |v| yield v }
      data[:exclude].map! { |v| yield v }
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
    field = 'chapters' if klass == Manga && field == 'episodes'
    field = 'episodes' if klass == Anime && (field == 'chapters' || field == 'volumes')

    case field
      when 'name'
        "#{klass.table_name}.name, #{klass.table_name}.id"

      when 'russian'
        <<-SQL.squish
          (case
            when #{klass.table_name}.russian is null
              or #{klass.table_name}.russian=''
            then #{klass.table_name}.name
            else #{klass.table_name}.russian
          end), #{klass.table_name}.id
        SQL

      when 'episodes'
        <<-SQL.squish
          (case
            when #{klass.table_name}.episodes = 0
            then #{klass.table_name}.episodes_aired
            else #{klass.table_name}.episodes
          end) desc, #{klass.table_name}.id
        SQL

      when 'chapters'
        "#{klass.table_name}.chapters desc, #{klass.table_name}.id"

      when 'volumes'
        "#{klass.table_name}.volumes desc, #{klass.table_name}.id"

      when 'status'
        <<-SQL.squish
          (case
            when #{klass.table_name}.status='Not yet aired'
              or #{klass.table_name}.status='Not yet published'
            then 'AAA'
            else
              (case
                when #{klass.table_name}.status='Publishing'
                then 'Currently Airing'
                else #{klass.table_name}.status
              end)
          end), #{klass.table_name}.id
        SQL

      when 'popularity'
        <<-SQL.squish
          (case
            when popularity=0
            then 999999
            else popularity
          end), #{klass.table_name}.id
        SQL

      when 'ranked'
        <<-SQL.squish
          (case
            when ranked=0
            then 999999
            else ranked
          end), #{klass.table_name}.score desc, #{klass.table_name}.id
        SQL

      when 'released_on'
        <<-SQL.squish.strip
          (case
            when released_on is null
            then aired_on
            else released_on
          end) desc, #{klass.table_name}.id
        SQL

      when 'aired_on'
        "aired_on desc, #{klass.table_name}.id"

      when 'id'
        "#{klass.table_name}.id desc"

      when 'rate_id'
        "user_rates.id, #{klass.table_name}.id"

      when 'my', 'rate'
        <<-SQL.squish
          user_rates.score desc,
          #{klass.table_name}.name,
          #{klass.table_name}.id
        SQL

      when 'site_score'
        "#{klass.table_name}.site_score desc, #{klass.table_name}.id"

      when 'kind'
        "#{klass.table_name}.kind, #{klass.table_name}.id"

      when 'user_1', 'user_2' # кастомные сортировки
        nil

      when 'random'
        'random()'

      else
        #raise ArgumentError, "unknown order '#{field}'"
        order_sql DEFAULT_ORDER, klass
    end
  end
end
