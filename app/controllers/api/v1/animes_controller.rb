# TODO: remove type param after 2018-06-01
class Api::V1::AnimesController < Api::V1Controller # rubocop:disable ClassLength
  before_action :fetch_resource, except: %i[index search neko]

  caches_action :neko, expires_in: 1.week, cache_path: -> {
    NekoRepository.instance.cache_key(
      params[:controller],
      params[:action],
      Anime.count,
      :v1
    ).to_json
  }

  LIMIT = 50
  ORDERS = %w[
    id id_desc ranked kind popularity name aired_on episodes status
    created_at created_at_desc random
  ]
  ORDERS_DESC = ORDERS.inject('') do |memo, order|
    memo + <<~DOC
      <p><code>#{order}</code> &ndash;
      #{I18n.t("by.#{order}", locale: :en).downcase}
      </p>
    DOC
  rescue I18n::NoTranslation
    memo
  end
  DURATIONS = I18n.t('animes_collection.menu.anime.duration', locale: :en)
  DURATIONS_DESC = DURATIONS
    .map { |(k, v)| "<p><code>#{k}</code> &ndash; #{v.downcase}</p>" }
    .join('') + <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{DURATIONS.keys.join '</code>, <code>'}</code>
        </li>
      </ul>
    DOC
  RATINGS = I18n.t('enumerize.anime.rating.hint', locale: :en)
  RATINGS_DESC = RATINGS
    .map { |(k, v)| "<p><code>#{k}</code> &ndash; #{ERB::Util.h v}</p>" }
    .join('') + <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{RATINGS.keys.join '</code>, <code>'}</code>
        </li>
      </ul>
    DOC

  api :GET, '/animes', 'List animes'
  description <<~DOC
    <p>
      Most of parameters can be grouped in lists of values separated by comma:
      <ul>
        <li>
          <code>season=2016,2015</code> &ndash;
          animes with season <code>2016 year</code>
          or with season <code>2015 year</code>
        </li>
        <li>
          <code>kind=tv,movie</code> &ndash;
          animes with kind <code>TV</code> or with kind <code>Movie</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the subtraction mode:
      <ul>
        <li>
          <code>season=!2016,!2015</code> &ndash;
          animes without season <code>2016 year</code>
          and without season <code>2015 year</code>
        </li>
        <li>
          <code>kind=!tv,!movie</code> &ndash;
          animes without kind <code>TV</code>
          and without kind <code>Movie</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the combined mode:
      <ul>
        <li>
          <code>season=2016,!summer_2016</code> &ndash;
          animes with season <code>2016 year</code> and
          without season <code>summer_2016</code>
        </li>
      </ul>
    </p>
  DOC
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  param :order, ORDERS,
    required: false,
    allow_blank: true,
    desc: ORDERS_DESC
  param :type, :undef,
    required: false,
    allow_blank: true,
    desc: 'Deprecated'
  param :kind, :undef,
    required: false,
    allow_blank: true,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{(Anime.kind.values + %i[tv_13 tv_24 tv_48]).join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :status, :undef,
    required: false,
    allow_blank: true,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Anime.status.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :season, :undef,
    required: false,
    allow_blank: true,
    desc: <<~DOC
      <p><strong>Examples:</strong></p>
      <p><code>summer_2017</code></p>
      <p><code>2016</code></p>
      <p><code>2014_2016</code></p>
      <p><code>199x</code></p>
    DOC
  param :score, :number,
    required: false,
    allow_blank: true,
    desc: 'Minimal anime score'
  param :duration, :undef,
    required: false,
    allow_blank: true,
    desc: DURATIONS_DESC
  param :rating, :undef,
    required: false,
    allow_blank: true,
    desc: RATINGS_DESC
  param :genre, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of genre ids separated by comma'
  param :studio, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of studio ids separated by comma'
  param :franchise, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of franchises separated by comma'
  param :censored, %w[true false],
    required: false,
    allow_blank: true,
    desc: 'Set to `false` to allow hentai, yaoi and yuri'
  param :mylist, :undef,
    required: false,
    allow_blank: true,
    desc: <<~DOC
      <p>Status of manga in current user list</p>
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{UserRate.statuses.keys.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :ids, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of anime ids separated by comma'
  param :exclude_ids, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of anime ids separated by comma'
  param :search, String,
    required: false,
    allow_blank: true,
    desc: 'Search phrase to filter animes by `name`'
  def index
    limit = [[params[:limit].to_i, 1].max, LIMIT].min

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AnimesCollection::PageQuery.call(
        klass: Anime,
        filters: params,
        user: current_user,
        limit: limit
      ).collection
    end

    respond_with @collection, each_serializer: AnimeSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id', 'Show an anime'
  def show
    respond_with @resource,
      serializer: AnimeProfileSerializer,
      scope: view_context
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/roles'
  def roles
    @collection = @resource.person_roles.includes(:character, :person)
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/similar'
  def similar
    @collection = @resource.related.similar
    respond_with @collection, each_serializer: AnimeSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/related'
  def related
    @collection = @resource.related.all
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/screenshots'
  def screenshots
    @collection = @resource.object.screenshots
    respond_with @collection
  end

  # TODO: delete after 01.01.2017
  api :GET, '/animes/:id/videos', 'Use Videos API instead', deprecated: true
  def videos
    @collection = @resource.object.videos
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/franchise'
  def franchise
    respond_with @resource, serializer: FranchiseSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/external_links'
  def external_links
    @collection = @resource.available_external_links
    respond_with @collection
  end

  api :GET, '/animes/search', 'Use "List animes" API instead', deprecated: true
  def search
    params[:limit] ||= 16
    index
  end

  api :GET, '/animes/:id/topics'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{Api::V1::TopicsController::LIMIT} maximum"
  param :kind, Types::Topic::NewsTopic::Action.values.map(&:to_s), required: false
  param :episode, :number, required: false
  def topics # rubocop:disable AbcSize
    @limit = [[params[:limit].to_i, 1].max, Api::V1::TopicsController::LIMIT].min

    scope = Topics::Query.new(@resource.all_topics)
      .where(locale: locale_from_host)

    scope = scope.where action: params[:kind] if params[:kind].present?
    scope = scope.where value: params[:episode] if params[:episode].present?

    @collection = scope
      .includes(:forum, :user)
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)
      .as_views(true, false)

    respond_with @collection, each_serializer: TopicSerializer
  end

  def neko # rubocop:disable MethodLength
    scope = Animes::NekoScope.call
      .select(
        :id,
        :aired_on,
        :genre_ids,
        :status,
        :episodes,
        :episodes_aired,
        :duration,
        :franchise
      )

    data = scope.map do |anime|
      {
        id: anime.id,
        genre_ids: anime.genre_ids.map(&:to_i),
        episodes: Neko::Episodes.call(anime),
        duration: anime.duration,
        year: anime.year,
        franchise: anime.franchise
      }
    end

    render json: data
  end

private

  def cache_key
    XXhash.xxh32([
      request.path,
      params.to_json,
      params[:mylist].present? ? current_user.try(:cache_key) : nil,
      (Time.zone.today if params[:order] == 'random'),
      :v2
    ].join('|'))
  end

  def fetch_resource
    @resource = Anime.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
