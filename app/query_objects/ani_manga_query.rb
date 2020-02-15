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
    @query = Animes::Query.fetch(
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
        studio: @studio
      },
      user: @user
    )

    if @exclude_ai_genres
      @query = @query.exclude_ai_genres @user.sex
    end

    censored!
    disable_music!

    order @query
  end

  # сортировка по параметрам
  def order query
    if @search.blank?
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
