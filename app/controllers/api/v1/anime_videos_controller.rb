class Api::V1::AnimeVideosController < Api::V1::ApiController
  respond_to :json
  before_action :fetch_anime

  load_and_authorize_resource only: [:create]

  def index
    @collection = @anime.anime_videos.order(:episode)
    respond_with @collection, each_serializer: AnimeVideoSerializer
  end

  def create
    @resource = AnimeVideosService.new(create_params).create(current_user)
    respond_with @resource
  end

private

  def fetch_anime
    @anime = Anime.find(
      CopyrightedIds.instance.restore_id(params[:anime_id])
    ).decorate
  end

  def create_params
    params
      .require(:anime_video)
      .permit(*AnimeOnline::AnimeVideosController::CREATE_PARAMS)
  end
end
