class Api::V1::AnimesController < Api::V1Controller
  before_action :fetch_resource, except: [:index, :search]

  LIMIT = 50
  ORDERS = %w(
    ranked type popularity name aired_on episodes status random
  )

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
          <code>type=tv,movie</code> &ndash;
          animes with type <code>TV</code> or with type <code>Movie</code>
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
          <code>type=!tv,!movie</code> &ndash;
          animes without type <code>TV</code>
          and without type <code>Movie</code>
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
  param :page, :number, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  param :order, ORDERS,
    required: false,
    desc: (ORDERS.inject('') do |memo, order|
      memo +
        if order == 'random'
          '<p><code>random</code> &ndash; in random order</p>'
        else
          <<~DOC
            <p><code>#{order}</code> &ndash;
            #{I18n.t("by.#{order.gsub('type', 'kind')}", locale: :en).downcase}
            </p>
          DOC
        end
    end)
  param :type, Anime.kind.values, required: false
  param :status, Anime.status.values, required: false
  param :season, :undef,
    required: false,
    desc: <<~DOC
      <p><strong>Examples:</strong></p>
      <p><code>summer_2017</code></p>
      <p><code>2016</code></p>
      <p><code>2014-2016</code></p>
      <p><code>199x</code></p>
    DOC
  param :score, :number, required: false, desc: 'Minimal anime score'
  param :duration, Types::Anime::Duration.values.map(&:to_s),
    required: false,
    desc: I18n.t('animes_collection.menu.anime.duration', locale: :en)
      .map { |(k, v)| "<p><code>#{k}</code> &ndash; #{v.downcase}</p>" }
      .join('')
  param :rating, Anime.rating.values,
    required: false,
    desc: I18n.t('enumerize.anime.rating.hint', locale: :en)
      .map { |(k, v)| "<p><code>#{k}</code> &ndash; #{ERB::Util.h v}</p>" }
      .join('')
  param :genre, :undef,
    required: false,
    desc: 'List of genre ids separated by comma'
  param :studio, :undef,
    required: false,
    desc: 'List of studio ids separated by comma'
  param :censored, %w(true false),
    required: false,
    desc: 'Set to `false` to allow hentai, yaoi and yuri'
  param :mylist, :undef,
    required: false,
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
  param AniMangaQuery::IDS_KEY, :undef,
    required: false,
    desc: 'List of anime ids separated by comma'
  param AniMangaQuery::EXCLUDE_IDS_KEY, :undef,
    required: false,
    desc: 'List of anime ids separated by comma'
  param :search, String,
    required: false,
    desc: 'Search phrase to filter animes by `name`'
  def index
    limit = [[params[:limit].to_i, 1].max, 50].min

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AnimesCollection::PageQuery.call(
        klass: Anime,
        params: params,
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
    @collection = @resource.screenshots
    respond_with @collection
  end

  # TODO: delete after 01.01.2017
  api :GET, '/animes/:id/videos', 'Use Videos API instead', deprecated: true
  def videos
    @collection = @resource.videos
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:id/franchise'
  def franchise
    respond_with @resource, serializer: FranchiseSerializer
  end

  api :GET, '/animes/search', 'Use "List animes" API instead', deprecated: true
  def search
    params[:limit] ||= 16
    index
  end

private

  def cache_key
    Digest::MD5.hexdigest([
      request.path,
      params.to_json,
      params[:mylist].present? ? current_user.try(:cache_key) : nil
    ].join('|'))
  end

  def fetch_resource
    @resource = Anime.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
