class Api::V1::AnimesController < Api::V1::ApiController
  serialization_scope :view_context
  respond_to :json

  before_action :fetch_resource, except: [:index, :search]

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes', 'List animes'
  def index
    limit = [[params[:limit].to_i, 1].max, 30].min
    page = [params[:page].to_i, 1].max

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AniMangaQuery
        .new(Anime, params, current_user)
        .fetch(page, limit)
        .to_a
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

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/search'
  def search
    @collection = AniMangaQuery.new(
      Anime,
      {
        search: params[:q],
        censored: (params[:censored] == 'true' if params[:censored].present?)
      },
      current_user
    ).complete
    respond_with @collection, each_serializer: AnimeSerializer
  end

private

  def cache_key
    Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{params[:mylist].present? ? current_user.try(:cache_key) : nil}"
  end

  def fetch_resource
    @resource = Anime.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
