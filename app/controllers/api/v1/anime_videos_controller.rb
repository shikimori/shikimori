class Api::V1::AnimeVideosController < Api::V1Controller
  before_action :fetch_anime

  load_and_authorize_resource only: %i[create destroy]

  def index
    raise CanCan::AccessDenied unless access_granted?

    @collection = @anime.anime_videos.order(:episode)
    respond_with @collection, each_serializer: AnimeVideoSerializer
  end

  api :POST, '/animes/:anime_id/anime_videos', 'Create an anime episode video'
  param :anime_video, Hash, required: true do
    param :anime_id, :number, required: true
    param :author_name, :undef
    param :episode, :number, required: true
    param :kind, %w[raw subtitles fandub unknown], required: true
    param :language, %w[russian english original unknown], required: true
    param :quality, %w[bd web tv dvd unknown], required: true
    param :url, String, required: true, desc: 'Link to the video'
    param :source, String,
      required: true,
      desc: 'Link to the page from where you got the video'
  end
  def create
    @resource = AnimeOnline::VideosService.new(create_params).create(current_user)
    respond_with @resource
  end

  def destroy
    @resource.destroy
    head 204
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
      .tap do |anime_video|
        anime_video[:state] = 'uploaded'
      end
  end

  def access_granted?
    current_user&.trusted_video_uploader? ||
      params[:video_token] ==
        Rails.application.secrets[:api][:anime_videos][:token]
  end
end
