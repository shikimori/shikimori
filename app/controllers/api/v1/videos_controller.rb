class Api::V1::VideosController < Api::V1Controller
  before_action :authenticate_user!, except: [:index]
  before_action :fetch_anime

  before_action except: %i[index] do
    doorkeeper_authorize! :content if doorkeeper_token.present?
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/animes/:anime_id/videos', 'List videos'
  def index
    @collection = @anime.videos
    respond_with @collection
  end

  api :POST, '/animes/:anime_id/videos', 'Create a video'
  description 'Requires `content` oauth scope'
  param :video, Hash do
    param :kind, Video.kind.values.map(&:to_s), required: true
    param :name, String, required: true
    param :url, String,
      required: true,
      desc: 'Supported hostings: ' + Video.hosting.values.map { |v| "<code>#{v}</code>" }.join(',')
  end
  def create
    @resource, @version = versioneer.upload video_params, current_user
    @resource = Video.find_by url: @resource.url if duplicate? @resource
    respond_with @resource
  end

  api :DELETE, '/animes/:anime_id/videos/:id', 'Destroy a video'
  description 'Requires `content` oauth scope'
  def destroy
    @version = versioneer.delete params[:id], current_user
    head 200
  end

private

  def video_params
    params
      .require(:video)
      .permit(:url, :kind, :name)
      .merge(uploader_id: current_user.id)
  end

  def versioneer
    Versioneers::VideosVersioneer.new @anime
  end

  def duplicate? video
    video.errors.one? &&
      video.errors[:url] == Array(I18n.t('activerecord.errors.messages.taken'))
  end

  def fetch_anime
    @anime = Anime.find_by(
      id: CopyrightedIds.instance.restore(params[:anime_id], 'anime')
    )&.decorate
  end
end
