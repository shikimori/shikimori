# TODO: remove type param after 2018-06-01
class Api::V1::MangasController < Api::V1Controller # rubocop:disable ClassLength
  before_action :fetch_resource, except: %i[index search neko]

  caches_action :neko, expires_in: 1.week, cache_path: -> {
    NekoRepository.instance.cache_key(
      params[:controller],
      params[:action],
      Manga.count,
      :v1
    ).to_json
  }

  LIMIT = 50
  ORDERS = %w[
    id id_desc ranked kind popularity name aired_on volumes chapters status
    random ranked_random ranked_shiki
    created_at created_at_desc
  ]
  TRANSLATED_ORDERS = I18n.t('by').keys.map(&:to_s)
  ORDERS_DESC = ORDERS.inject('') do |memo, order|
    memo + <<~DOC
      <p><code>#{order}</code> &ndash;
      #{I18n.t("by.#{order}", locale: :en).downcase}#{'. <b>Will be removed. Do not use it.</b>' if order.include? 'ranked_'}
      </p>
    DOC
  rescue I18n::NoTranslation
    memo
  end

  api :GET, '/mangas', 'List mangas'
  description <<~DOC
    <p>
      Most of parameters can be grouped in lists of values separated by comma:
      <ul>
        <li>
          <code>season=2016,2015</code> &ndash;
          mangas with season <code>2016 year</code>
          or with season <code>2015 year</code>
        </li>
        <li>
          <code>kind=manga,one_shot</code> &ndash;
          mangas with kind <code>Manga</code> or with kind <code>One Shot</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the subtraction mode:
      <ul>
        <li>
          <code>season=!2016,!2015</code> &ndash;
          mangas without season <code>2016 year</code>
          and without season <code>2015 year</code>
        </li>
        <li>
          <code>kind=!manga,!one_shot</code> &ndash;
          mangas without kind <code>Manga</code>
          and without kind <code>One Shot</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the combined mode:
      <ul>
        <li>
          <code>season=2016,!summer_2016</code> &ndash;
          mangas with season <code>2016 year</code> and
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
          <code>#{Manga.kind.values.join('</code>, <code>')}</code>
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
          <code>#{Manga.status.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :season, :undef,
    required: false,
    allow_blank: true,
    desc: <<~DOC
      <p><strong>Examples:</strong></p>
      <p><code>summer_2017</code></p>
      <p><code>spring_2016,fall_2016</code></p>
      <p><code>2016,!winter_2016</code></p>
      <p><code>2016</code></p>
      <p><code>2014_2016</code></p>
      <p><code>199x</code></p>
    DOC
  param :score, :number,
    required: false,
    allow_blank: true,
    desc: 'Minimal manga score'
  param :genre, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of genre ids separated by comma'
  param :publisher, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of publisher ids separated by comma'
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
    desc: 'List of manga ids separated by comma'
  param :exclude_ids, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of manga ids separated by comma'
  param :search, String,
    required: false,
    allow_blank: true,
    desc: 'Search phrase to filter mangas by `name`'
  def index
    limit = [[params[:limit].to_i, 1].max, LIMIT].min

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AnimesCollection::PageQuery.call(
        klass: Manga,
        filters: params,
        user: current_user,
        limit: limit
      ).collection
    end

    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id', 'Show a manga'
  def show
    respond_with @resource,
      serializer: MangaProfileSerializer,
      scope: view_context
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/roles'
  def roles
    @collection = @resource.person_roles.includes(:character, :person)
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/similar'
  def similar
    @collection = @resource.related.similar
    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/related'
  def related
    @collection = @resource.related.all
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/franchise'
  def franchise
    respond_with @resource, serializer: FranchiseSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id/external_links'
  def external_links
    @collection = @resource.available_external_links
    respond_with @collection
  end

  api :GET, '/mangas/search', 'Use "List mangas" API instead', deprecated: true
  def search
    params[:limit] ||= 16
    index
  end

  api :GET, '/mangas/:id/topics'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{Api::V1::TopicsController::LIMIT} maximum"
  def topics
    @limit = [[params[:limit].to_i, 1].max, Api::V1::TopicsController::LIMIT].min

    @collection = Topics::Query
      .new(@resource.all_topics)
      .where(locale: locale_from_host)
      .includes(:forum, :user)
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)
      .as_views(true, false)

    respond_with @collection, each_serializer: TopicSerializer
  end

  def neko
    scope = Mangas::NekoScope.call
      .select(
        :id,
        :aired_on,
        :genre_ids
      )

    data = scope.map do |manga|
      {
        id: manga.id,
        genre_ids: manga.genre_ids.map(&:to_i),
        year: manga.year
      }
    end

    render json: data
  end

private

  def cache_key # rubocop:disable AbcSize
    XXhash.xxh32([
      request.path,
      params.to_json,
      params[:mylist].present? ? current_user.try(:cache_key) : nil,
      ((rand * 1000).to_i if params[:order] == 'random'),
      (Time.zone.today if params[:order] == 'ranked_random')
    ].join('|'))
  end

  def fetch_resource
    @resource = Manga.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
