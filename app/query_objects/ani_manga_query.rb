# TODO: refactor to bunch of simplier query objects
class AniMangaQuery
  IDS_KEY = :ids
  EXCLUDE_IDS_KEY = :exclude_ids
  EXCLUDE_AI_GENRES_KEY = :exclude_ai_genres

  DEFAULT_ORDER = 'ranked'
  GENRES_EXCLUDED_BY_SEX = {
    'male' => Genre::YAOI_IDS + Genre::SHOUNEN_AI_IDS,
    'female' => Genre::HENTAI_IDS + Genre::SHOUJO_AI_IDS + Genre::YURI_IDS,
    '' => Genre::CENSORED_IDS + Genre::SHOUNEN_AI_IDS + Genre::SHOUJO_AI_IDS
  }

  SEARCH_IDS_LIMIT = 250

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

    @mylist = params[:mylist].to_s.gsub(/\b\d\b/) do |status_id|
      UserRate.statuses.find { |_name, id| id == status_id.to_i }.first
    end

    # phrase is used in collection-search (userlist comparer)
    @search_phrase = params[:search] || params[:q] || params[:phrase]

    @exclude_ai_genres = params[EXCLUDE_AI_GENRES_KEY]

    @ids = params[IDS_KEY]
    @ids = @ids.split(',') if @ids.is_a? String

    @exclude_ids = params[EXCLUDE_IDS_KEY]
    @exclude_ids = @exclude_ids.split(',') if @exclude_ids.is_a? String

    @user = user

    # TODO: remove all after ||
    @order = params[:order] || (@search_phrase.blank? ? DEFAULT_ORDER : nil)
  end

  def fetch
    @query = Animes::Query.fetch(
      scope: @query,
      params: {
        kind: @kind,
        rating: @rating,
        duration: @duration,
        score: @score,
        franchise: @franchise,
        achievement: @achievement
      },
      user: @user
    )

    censored!
    disable_music!

    exclude_ai_genres!
    associations!

    season!
    status!

    mylist!

    ids!
    exclude_ids!
    search!

    order @query
  end

  def complete
    search!
    @query.limit(AUTOCOMPLETE_LIMIT).reverse
  end

  # сортировка по параметрам
  def order query
    if @search_phrase.blank?
      params_order query
    else
      query
    end
  end

private

  def mylist?
    @mylist.present? && @mylist !~ /^(!\w+,?)+$/
  end

  def userlist?
    !!@params[:userlist]
  end

  def search?
    @search_phrase.present?
  end

  def do_not_censore?
    [false, 'false'].include?(@params[:censored]) ||
      mylist? || userlist? ||
      @franchise.present? ||
      @achievement.present? ||
      @studio.present? ||
      @ids&.any?
  end

  def censored!
    if @genre
      genres = bang_split(@genre.split(','), true).each { |_k, v| v.flatten! }
    end
    ratings = bang_split @rating.split(',') if @rating

    rx = ratings && ratings[:include].include?(Anime::ADULT_RATING)
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

  # отключение всего зацензуренной для парней/девушек
  def exclude_ai_genres!
    return unless @exclude_ai_genres && @user
    return if do_not_censore?

    excludes = GENRES_EXCLUDED_BY_SEX[@user.sex || '']

    @genre =
      if @genre.present?
        "#{@genre},!#{excludes.join ',!'}"
      else
        "!#{excludes.join ',!'}"
      end
  end

  # фильтрация по жанрам, студиям и издателям
  def associations!
    [
      [Genre, @genre],
      [Studio, @studio],
      [Publisher, @publisher]
    ].each do |association_klass, values|
      association! association_klass, values if values.present?
    end
  end

  def association! association_klass, values
    ids = bang_split(values.split(','), true) do |v|
      association_klass.related(v.to_i)
    end
    field = "#{association_klass.name.downcase}_ids"

    ids[:include].each do |ids|
      @query.where! "#{field} && '{#{ids.map(&:to_i).join ','}}'"
    end
    ids[:exclude].each do |ids|
      @query.where! "not (#{field} && '{#{ids.map(&:to_i).join ','}}')"
    end
  end

  # фильтрация по сезонам
  def season!
    return if @season.blank?

    seasons = bang_split @season.split(',')

    query = seasons[:include].map do |season|
      Animes::SeasonQuery.call(@klass.all, season).to_where_sql
    end
    @query = @query.where query.join(' OR ') unless query.empty?

    query = seasons[:exclude].map do |season|
      'NOT (' +
        Animes::SeasonQuery.call(@klass.all, season).to_where_sql +
        ')'
    end
    @query = @query.where query.join(' AND ') unless query.empty?
  end

  # фильтрация по статусам
  def status!
    return if @status.blank?

    statuses = bang_split @status.split(',')

    query = statuses[:include].map do |status|
      Animes::StatusQuery.call(@klass.all, status).to_where_sql
    end
    @query = @query.where query.join(' OR ') unless query.empty?

    query = statuses[:exclude].map do |status|
      'NOT (' +
        Animes::StatusQuery.call(@klass.all, status).to_where_sql +
        ')'
    end
    @query = @query.where query.join(' AND ') unless query.empty?
  end

  # фильтрация по наличию в собственном списке
  def mylist!
    return if @mylist.blank? || @user.blank?

    statuses = bang_split(@mylist.split(','), false)

    animelist = @user
      .send("#{@klass.base_class.name.downcase}_rates")
      .includes(@klass.base_class.name.downcase.to_sym)
      .each_with_object(include: [], exclude: []) do |entry, memo|
        if statuses[:include].include?(entry.status)
          memo[:include] << entry.target_id
        end

        if statuses[:exclude].include?(entry.status)
          memo[:exclude] << entry.target_id
        end
      end

    animelist[:include] << 0 if statuses[:include].any? && animelist[:include].none?
    animelist[:exclude] << 0 if statuses[:exclude].any? && animelist[:exclude].none?

    @query = @query.where(id: animelist[:include]) if animelist[:include].any?
    @query = @query.where.not(id: animelist[:exclude]) if animelist[:exclude].any?
  end

  # фильтрация по id
  def ids!
    return if @ids.blank?

    @query = @query.where(id: @ids.map(&:to_i))
  end

  # фильтрация по id
  def exclude_ids!
    return if @exclude_ids.blank?

    @query = @query.where.not(id: @exclude_ids.map(&:to_i))
  end

  # поиск по названию
  def search!
    return if @search_phrase.blank?

    @query = "Search::#{@klass.name}".constantize.call(
      scope: @query,
      phrase: @search_phrase,
      ids_limit: SEARCH_IDS_LIMIT
    )
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

  # sql представление сортировки датасорса
  def self.order_sql field, klass
    if klass == Manga && field == 'episodes'
      field = 'chapters'
    elsif klass == Anime && %w[chapters volumes].include?(field)
      field = 'episodes'
    end

    sql = case field
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

      when 'rate_updated'
        "user_rates.updated_at desc, user_rates.id, #{klass.table_name}.id"

      when 'my', 'rate'
        <<-SQL.squish
          user_rates.score desc,
          #{klass.table_name}.name,
          #{klass.table_name}.id
        SQL

      when 'site_score'
        "#{klass.table_name}.site_score desc, #{klass.table_name}.id"

      when 'kind', 'type'
        "#{klass.table_name}.kind, #{klass.table_name}.id"

      when 'user_1', 'user_2' # кастомные сортировки
        nil

      when 'random'
        'random()'

      else
        # raise ArgumentError, "unknown order '#{field}'"
        order_sql DEFAULT_ORDER, klass
    end

    Arel.sql(sql) if sql
  end
end
