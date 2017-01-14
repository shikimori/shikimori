class Api::V1::MangasController < Api::V1Controller
  serialization_scope :view_context

  respond_to :json
  before_action :fetch_resource, except: [:index, :search]

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas', 'List mangas'
  def index
    limit = [[params[:limit].to_i, 1].max, 30].min

    @collection = Rails.cache.fetch cache_key, expires_in: 2.days do
      AnimesCollection::PageQuery.call(
        klass: Manga,
        params: params,
        user: current_user,
        limit: limit
      ).collection
    end

    respond_with @collection, each_serializer: MangaSerializer
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/mangas/:id', 'Show a manga'
  def show
    respond_with Manga.find(params[:id]).decorate,
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

  api :GET, '/mangas/search', 'Use "List mangas" API instead', deprecated: true
  def search
    params[:limit] ||= 16
    index
  end

private

  def cache_key
    Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{params[:mylist].present? ? current_user.try(:cache_key) : nil}"
  end

  def fetch_resource
    @resource = Manga.find(
      CopyrightedIds.instance.restore_id(params[:id])
    ).decorate
  end
end
