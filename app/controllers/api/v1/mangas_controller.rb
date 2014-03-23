class Api::V1::MangasController < Api::V1::ApiController
  respond_to :json, :xml
  before_action :fetch_resource, except: [:index]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas", "List mangas"
  def index
    limit = [[params[:limit].to_i, 1].max, 30].min
    page = [params[:page].to_i, 1].max

    @collection = Rails.cache.fetch cache_key do
      AniMangaQuery
        .new(Manga, params, current_user)
        .fetch(page, limit)
        .to_a
    end

    respond_with @collection, each_serializer: MangaSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas/:id", "Show a manga"
  def show
    respond_with Manga.find(params[:id]).decorate, serializer: MangaProfileSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas/:id/roles"
  def roles
    @collection = @resource.person_roles.includes(:character, :person)
    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas/:id/similar"
  def similar
    @collection = @resource.related.similar
    respond_with @collection, each_serializer: MangaSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas/:id/related"
  def related
    @collection = @resource.related.all
    respond_with @collection
  end

private
  def cache_key
    Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{params[:mylist].present? ? current_user.try(:cache_key) : nil}"
  end

  def fetch_resource
    @resource = Manga.find(params[:id]).decorate
  end
end
