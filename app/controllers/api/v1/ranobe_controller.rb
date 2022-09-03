class Api::V1::RanobeController < Api::V1::MangasController
  before_action :fetch_resource, except: %i[index search]

  api :GET, '/ranobe', 'List ranobe'
  description <<~DOC
    <p>
      Most of parameters can be grouped in lists of values separated by comma:
      <ul>
        <li>
          <code>season=2016,2015</code> &ndash;
          ranobe with season <code>2016 year</code>
          or with season <code>2015 year</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the subtraction mode:
      <ul>
        <li>
          <code>season=!2016,!2015</code> &ndash;
          ranobe without season <code>2016 year</code>
          and without season <code>2015 year</code>
        </li>
      </ul>
    </p>
    <p>
      Most of the parameters can be used in the combined mode:
      <ul>
        <li>
          <code>season=2016,!summer_2016</code> &ndash;
          ranobe with season <code>2016 year</code> and
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
  param :status, :undef,
    required: false,
    allow_blank: true,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Ranobe.status.values.join('</code>, <code>')}</code>
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
    desc: 'Minimal ranobe score'
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
      <p>Status of ranobe in current user list</p>
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
    desc: 'List of ranobe ids separated by comma'
  param :exclude_ids, :undef,
    required: false,
    allow_blank: true,
    desc: 'List of ranobe ids separated by comma'
  param :search, String,
    required: false,
    allow_blank: true,
    desc: 'Search phrase to filter ranobe by `name`'
  def index
    limit = [[params[:limit].to_i, 1].max, 30].min

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AnimesCollection::PageQuery.call(
        klass: Ranobe,
        filters: params,
        user: current_user,
        limit: limit
      ).collection
    end

    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/ranobe/:id', 'Show a ranobe'
  def show
    respond_with @resource,
      serializer: MangaProfileSerializer,
      scope: view_context
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/ranobe/:id/roles'
  def roles
    @collection = @resource.person_roles.includes(:character, :person)
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/ranobe/:id/similar'
  def similar
    @collection = @resource.related.similar
    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/ranobe/:id/related'
  def related
    @collection = @resource.related.all
    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/ranobe/:id/franchise'
  def franchise
    respond_with @resource, serializer: FranchiseSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/ranobe/:id/external_links'
  def external_links
    @collection = @resource.available_external_links
    respond_with @collection
  end

  api :GET, '/ranobe/:id/topics'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{Api::V1::TopicsController::LIMIT} maximum"
  def topics
    @limit = [[params[:limit].to_i, 1].max, Api::V1::TopicsController::LIMIT].min

    @collection = Topics::Query.new(@resource.all_topics)
      .includes(:forum, :user)
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)
      .as_views(true, false)

    respond_with @collection, each_serializer: TopicSerializer
  end

private

  def fetch_resource
    @resource = Ranobe.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
