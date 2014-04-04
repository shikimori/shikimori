class Api::V1::AnimesController < Api::V1::ApiController
  respond_to :json, :xml

  before_action :fetch_resource, except: [:index]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes", "List animes"
  def index
    limit = [[params[:limit].to_i, 1].max, 30].min
    page = [params[:page].to_i, 1].max

    @collection = Rails.cache.fetch cache_key do
      AniMangaQuery
        .new(Anime, params, current_user)
        .fetch(page, limit)
        .to_a
    end

    respond_with @collection, each_serializer: AnimeSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id", "Show an anime"
  def show
    respond_with @resource, serializer: AnimeProfileSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id/roles"
  def roles
    @collection = @resource.person_roles.includes(:character, :person)
    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id/similar"
  def similar
    @collection = @resource.related.similar
    respond_with @collection, each_serializer: AnimeSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id/related"
  def related
    @collection = @resource.related.all
    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id/screenshots"
  def screenshots
    @collection = @resource.screenshots
    respond_with @collection
  end

private
  def cache_key
    Digest::MD5.hexdigest "#{request.path}|#{params.to_json}|#{params[:mylist].present? ? current_user.try(:cache_key) : nil}"
  end

  def fetch_resource
    @resource = Anime.find(params[:id]).decorate
  end
end
