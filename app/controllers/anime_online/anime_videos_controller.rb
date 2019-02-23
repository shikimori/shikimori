class AnimeOnline::AnimeVideosController < AnimesController # rubocop:disable ClassLength
  load_and_authorize_resource only: %i[new create edit update destroy]

  before_action :actualize_resource, only: %i[new create edit update]
  before_action :authenticate_user!, only: %i[viewed]
  before_action :add_breadcrumb, except: %i[index destroy]

  before_action :redirect_copyrighted, only: %i[index]

  skip_before_action :verify_authenticity_token, only: %i[track_view]

  before_action { @anime_online_ad = true }
  after_action :save_preferences, only: :index

  CREATE_PARAMS = %i[
    episode author_name url anime_id source state kind language quality
  ]

  def index
    raise ActionController::RoutingError, 'Not Found' if @anime.forbidden?

    @player = AnimeOnline::VideoPlayer.new @anime
    @video = @player.current_video
    og page_title: @player.episode_title

    render partial: 'player_container' if request.xhr?
  end

  def new
    og page_title: 'Новое видео'

    if AnimeVideo::COPYRIGHT_BAN_ANIME_IDS.include?(@anime.id) &&
        (!user_signed_in? || !current_user.admin?)
      raise ActionController::RoutingError, 'Not Found'
    end
  end

  def edit
    og page_title: 'Изменение видео'
    @video = @video.decorate
  end

  # rubocop:disable MethodLength
  def create
    @video = AnimeOnline::VideosService.new(create_params).create(current_user)

    if @video.persisted?
      if params[:continue] == 'true'
        redirect_to(
          next_video_url(@video),
          notice: "Эпизод #{@video.episode} добавлен"
        )
      else
        redirect_to(
          play_video_online_index_url(@anime, @video.episode, @video.id),
          notice: 'Видео добавлено'
        )
      end
    else
      render :new
    end
  end

  def update
    @video = AnimeOnline::VideosService
      .new(
        current_user.video_moderator? ? moderator_update_params : update_params
      )
      .update(@video, current_user, params[:reason])
      .decorate

    if @video.errors.none? # there can be antispam error
      redirect_to(
        play_video_online_index_url(@anime, @video.episode, @video.id),
        notice: 'Видео изменено'
      )
    else
      og page_title: 'Изменение видео'
      render :edit
    end
  end
  # rubocop:enable MethodLength

  def destroy
    @resource.destroy

    redirect_to(
      play_video_online_index_url(@anime, @resource.episode),
      notice: 'Видео удалено'
    )
  end

  def viewed
    video = AnimeVideo.find params[:id]
    @user_rate = @anime.rates.find_or_initialize_by user: current_user

    if @user_rate.episodes < video.episode
      @user_rate.update! episodes: video.episode

      UserRates::Log.call(
        user_rate: @user_rate,
        ip: remote_addr,
        user_agent: request.user_agent,
        oauth_application_id: doorkeeper_token&.application_id
      )

      Achievements::Track.perform_async(
        @user_rate.user_id,
        @user_rate.id,
        Types::Neko::Action[:put]
      )
    end

    head 200
  end

  def track_view
    AnimeVideo.find(params[:id]).increment! :watch_view_count
    head 200
  end

  def extract_url
    if params[:url].present?
      url = VideoExtractor::PlayerUrlExtractor.call(Url.new(params[:url].strip).with_http.to_s)
    end

    render json: {
      player_html: (AnimeVideo.new(url: url).decorate.player_html if url)
    }
  end

private

  def redirect_copyrighted
    return if params[:no_redirect]

    if !ignore_copyright? || @resource.licensed? || @resource.censored? || @resource.forbidden?
      redirect_to anime_url @resource, subdomain: false
    end
  end

  def new_params
    create_params
  end

  def create_params
    params
      .require(:anime_video)
      .permit(*CREATE_PARAMS)
      .to_h
  end

  def update_params
    params
      .require(:anime_video)
      .permit(:episode, :author_name, :kind, :language, :quality)
      .to_h
  end

  def moderator_update_params
    params
      .require(:anime_video)
      .permit(:episode, :author_name, :kind, :url, :state, :language, :quality, :is_first)
      .to_h
      .tap do |params|
        # or else it will try to change "false" to "0" on every update
        params[:is_first] = params[:is_first] == '1'
      end
  end

  def resource_id
    params[:anime_id]
  end

  def resource_klass
    Anime
  end

  def save_preferences
    @player&.remember_video_preferences
  end

  def valid_host?
    AnimeOnlineDomain.valid_host? @anime, request
  end

  def valid_host_url
    play_video_online_index_url @anime,
      episode: params[:episode],
      video_id: params[:video_id],
      domain: AnimeOnlineDomain.host(@anime),
      subdomain: false
  end

  def next_video_url video
    new_video_online_url(
      'anime_video[anime_id]' => video.anime_id,
      'anime_video[source]' => video.source,
      'anime_video[state]' => :uploaded,
      'anime_video[kind]' => video.kind,
      'anime_video[language]' => video.language,
      'anime_video[quality]' => video.quality,
      'anime_video[episode]' => video.episode + 1,
      'anime_video[author_name]' => video.author_name
    )
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
