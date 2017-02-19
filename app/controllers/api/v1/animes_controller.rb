class Api::V1::AnimesController < Api::V1Controller
  before_action :fetch_resource, except: [:index, :search]

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes', 'List animes'
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
