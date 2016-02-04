class Api::V1::AnimeVideosController < Api::V1::ApiController
  respond_to :json
  before_action :fetch_anime

  before_filter :authenticate_user!, only: [:index]
  load_and_authorize_resource only: [:create]

  def index
    raise CanCan::AccessDenied unless current_user.trusted_video_uploader?

    @collection = @anime.anime_videos.order(:episode)
    respond_with @collection, each_serializer: AnimeVideoSerializer
  end

  api :POST, '/animes/:anime_id/anime_videos', 'Create an anime video'
  param :anime_video, Hash do
    param :anime_id, :number
    param :author_name, :undef
    param :episode, :number
    param :kind, %w(raw subtitles fandub unknown)
    param :language, %w(russian english japanese unknown)
    param :source, String
    param :url, String
  end
  def create
    create_params['state'] = 'uploaded'
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
