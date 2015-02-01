class AnimeOnline::AnimeVideosController < AnimesController
  load_and_authorize_resource only: [:new, :create, :edit, :update]

  before_action :actualize_resource, only: [:new, :create, :edit, :update]
  before_action :authenticate_user!, only: [:viewed]
  before_action :add_breadcrumb, except: [:index]

  before_action { @anime_online_ad = true }
  after_action :save_preferences, only: :index

  def index
    return redirect_to valid_host_url unless valid_host?
    raise ActionController::RoutingError.new('Not Found') if @anime.anime_videos.blank?

    @player = AnimeOnline::VideoPlayer.new @anime
    @video = @player.current_video
    page_title @player.episode_title
  end

  def new
    page_title 'Новое видео'
    raise ActionController::RoutingError.new 'Not Found' if AnimeVideo::CopyrightBanAnimeIDs.include?(@anime.id) && (!user_signed_in? || !current_user.admin?)
  end

  def edit
    page_title 'Изменение видео'
  end

  def create
    merged_params = create_params.merge(author_name: params[:anime_video][:author_name], url: params[:anime_video][:url])
    @video = AnimeVideosService.new(merged_params).create(current_user)

    if @video.persisted?
      if params[:continue] == 'true'
        flash[:notice] = "Эпизод #{@video.episode} добавлен"
        @created_video = @video
        @video = AnimeVideo.new @video.attributes.except(:id, :url)
      else
        return redirect_to play_video_online_index_url(@anime.id, @video.episode, @video.id), notice: 'Видео добавлено'
      end
    end

    page_title 'Новое видео'
    render :new
  end

  def update
    @video = AnimeVideosService.new(update_params).update(@video)

    if @video.valid?
      redirect_to play_video_online_index_url(@anime.id, @video.episode, @video.id), notice: 'Видео добавлено'
    else
      page_title 'Изменение видео'
      render :edit
    end
  end

  def help
  end

  def viewed
    video = AnimeVideo.find params[:id]
    @user_rate = @anime.rates.find_by(user_id: current_user.id) ||
      @anime.rates.build(user: current_user)

    @user_rate.update! episodes: video.episode if @user_rate.episodes < video.episode
    render nothing: true
  end

  def track_view
    AnimeVideo.find(params[:id]).increment! :watch_view_count
    render nothing: true
  end

  def extract_url
    render json: { url: VideoExtractor::UrlExtractor.new(params[:url]).extract }
  end

private
  def new_params
    create_params
  end

  def create_params
    params.require(:anime_video).permit(:episode, :anime_id, :source, :kind, :state)
  end

  def update_params
    params.require(:anime_video).permit(:episode, :author_name, :kind)
  end

  def resource_id
    params[:anime_id]
  end

  def resource_klass
    Anime
  end

  def save_preferences
    if @video && @video.persisted? && @video.valid?
      cookies[:preference_kind] = @video.kind
      cookies[:preference_hosting] = @video.hosting
      cookies[:preference_author_id] = @video.anime_video_author_id
    end
  end

  def valid_host?
    AnimeOnlineDomain::valid_host? @anime, request
  end

  def valid_host_url
    play_video_online_index_url @anime,
      episode: params[:episode], video_id: params[:video_id],
      domain: AnimeOnlineDomain::host(@anime), subdomain: false
  end

  def add_breadcrumb
    episode = @video.try(:episode)
    index_url = play_video_online_index_url(@anime, episode: episode)

    breadcrumb episode ? "Эпизод #{episode}" : 'Просмотр онлайн', index_url
    @back_url = index_url
  end

  def actualize_resource
    @video = @resource
    @resource = @anime
  end
end
