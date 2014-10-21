#TODO разделить аниме для play и xplay в #index, #show, #search
class AnimeOnline::AnimeVideosController < AnimeOnlineController
  #layout 'anime_online'

  before_filter :authenticate_user!, only: [:destroy, :rate, :viewed]
  after_filter :save_preferences, only: :show

  def show
    unless params[:search].blank?
      redirect_to anime_videos_url search: params[:search]
      return
    end

    @anime = AnimeVideoDecorator.new(
      Anime
        .includes(:anime_videos, :genres)
        .find params[:id])

    raise ActionController::RoutingError.new 'Not Found' if @anime.anime_videos.blank?

    unless AnimeOnlineDomain::valid_host? @anime, request
      redirect_to anime_videos_show_url @anime.id, domain: AnimeOnlineDomain::host(@anime), subdomain: false
      return
    end

    unless @anime.current_episode > 1
      @reviews = Comment
        .includes(:user)
        .where(commentable_id: @anime.thread)
        .reviews.order('id desc').limit 10
    end
  end

  def new
    anime = Anime.find params[:anime_id]
    raise ActionController::RoutingError.new 'Not Found' if AnimeVideo::CopyrightBanAnimeIDs.include?(anime.id) && (!user_signed_in? || !current_user.admin?)
    @video = AnimeVideo.new anime: anime, source: 'shikimori.org', kind: :fandub
  end

  def create
    @video = AnimeVideo.new video_params.merge(url: VideoExtractor::UrlExtractor.new(video_params[:url]).extract)
    @video.author = find_or_create_author params[:anime_video][:author].to_s.strip

    if @video.save
      AnimeOnline::AnimeVideosService.upload_report current_user, @video
      if params[:continue] == "true"
        flash[:notice] = "Эпизод #{@video.episode} добавлен"
        @video = AnimeVideo.new anime_id: @video.anime_id, episode: @video.episode + 1, author: @video.author, kind: @video.kind, source: 'shikimori.org'
        render :new
      else
        redirect_to anime_videos_show_url(@video.anime.id, @video.episode, @video.id), notice: 'Видео добавлено'
      end
    else
      render :new
    end
  end

  def edit
    @video = AnimeVideo.includes(:anime).find params[:id]
  end

  def update
    @video = AnimeVideo.find params[:id]
    author = find_or_create_author params[:anime_video][:author].to_s.strip
    if video_params[:episode] != @video.episode || video_params[:kind] != @video.kind || author.id != @video.author_id
      if @video.moderated_update video_params.merge(anime_video_author_id: author.id), current_user
        redirect_to anime_videos_show_url(@video.anime.id, @video.episode, @video.id), notice: 'Видео изменено'
      else
        render :edit
      end
    end
  end

  def destroy
    video = AnimeVideo.find(params[:id])
    report = AnimeVideoReport.where(user_id: current_user, anime_video_id: params[:id]).first
    if report
      video.destroy
    end
    redirect_to anime_videos_show_url(video.anime_id), notice: 'Видео удалено'
  end

  def help
  end

  def report
    user = user_signed_in? ? current_user : User.find(User::GuestID)
    anime_video = AnimeVideo.find params[:id]
    unless AnimeVideoReport.where(kind: params[:kind], anime_video_id: params[:id], user: user).first
      anime_report = AnimeVideoReport.find_or_create_by user: user, anime_video: anime_video
      anime_report.kind = params[:kind]
      anime_report.user_agent = request.user_agent
      anime_report.save
      anime_report.accept!(user) if user.admin?
    end
    render nothing: true
  end

  def extract_url
    render text: VideoExtractor::UrlExtractor.new(params[:url]).extract
  end

  def viewed
    video = AnimeVideo.find params[:id]
    anime = Anime.find params[:anime_id]
    user_rate = anime.rates.find_by_user_id current_user.id
    UserRate.update(user_rate.id, episodes: video.episode) if user_rate

    redirect_to anime_videos_show_url video.anime_id, video.episode + 1
  end

  def rate
    UserRate.create_or_find(current_user.id, params[:id], 'Anime').save
    render nothing: true
  end

  def watch_view_increment
    video = AnimeVideo.find params[:id]
    video.update watch_view_count: video.watch_view_count.to_i + 1
    render nothing: true
  end

private
  def video_params
    params
      .require(:anime_video)
      .permit(:episode, :url, :anime_id, :source, :kind)
      .merge(state: 'uploaded')
  end

  def find_or_create_author name
    AnimeVideoAuthor.where(name: name).first || AnimeVideoAuthor.create(name: name)
  end

  def save_preferences
    if params[:video_id].to_i > 0
      if video = AnimeVideo.find_by_id(params[:video_id])
        cookies[:preference_kind] = video.kind
        cookies[:preference_hosting] = video.hosting
        cookies[:preference_author_id] = video.anime_video_author_id
      end
    end
  end
end
