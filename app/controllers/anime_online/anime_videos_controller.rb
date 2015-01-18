#TODO разделить аниме для play и xplay в #index, #show, #search
class AnimeOnline::AnimeVideosController < AnimesController
  #layout 'anime_online'

  #before_action do
    #noindex
    #nofollow
  #end

  before_action :authenticate_user!, only: [:destroy, :rate, :viewed]
  before_action :check_redirect, only: :show
  after_action :save_preferences, only: :index

  def index
    @player = AnimeOnline::VideoPlayer.new @resource
    page_title @player.episode_title
    #raise ActionController::RoutingError.new 'Not Found' if @anime.anime_videos.blank?
  end

  def track_view
    AnimeVideo.find(params[:id]).increment! :watch_view_count
    render nothing: true
  end

  #def search
    #search = params[:search].to_s.strip
    #if search.blank?
      #redirect_to root_url
    #else
      #redirect_to anime_videos_url search: params[:search], page: 1
    #end
  #end

  #def new
    #anime = Anime.find params[:anime_id]
    #raise ActionController::RoutingError.new 'Not Found' if AnimeVideo::CopyrightBanAnimeIDs.include?(anime.id) && (!user_signed_in? || !current_user.admin?)
    #@video = AnimeVideo.new anime: anime, source: 'shikimori.org', kind: :fandub
  #end

  #def create
    #@video = AnimeVideo.new(video_params.merge(url: VideoExtractor::UrlExtractor.new(video_params[:url]).extract))
    #@video.author = find_or_create_author(params[:anime_video][:author])

    #if @video.save
      #AnimeVideoReport.create!(user: current_user, anime_video: @video, kind: :uploaded)

      #if params[:continue] == "true"
        #flash[:notice] = "Эпизод #{@video.episode} добавлен"
        #@video = AnimeVideo.new anime_id: @video.anime_id, episode: @video.episode + 1, author: @video.author, kind: @video.kind, source: 'shikimori.org'
        #render :new
      #else
        #redirect_to anime_videos_show_url(@video.anime.id, @video.episode, @video.id), notice: 'Видео добавлено'
      #end
    #else
      #render :new
    #end
  #end

  #def edit
    #@video = AnimeVideo.includes(:anime).find params[:id]
  #end

  #def update
    #@video = AnimeVideo.find(params[:id])
    #author = find_or_create_author(params[:anime_video][:author])
    #if video_params[:episode] != @video.episode || video_params[:kind] != @video.kind || author.id != @video.author_id
      #if @video.moderated_update video_params.merge(anime_video_author_id: author.id), current_user
        #redirect_to anime_videos_show_url(@video.anime.id, @video.episode, @video.id), notice: 'Видео изменено'
      #else
        #render :edit
      #end
    #end
  #end

  #def destroy
    #video = AnimeVideo.find(params[:id])
    #report = AnimeVideoReport.where(user_id: current_user, anime_video_id: params[:id]).first
    #if report
      #video.destroy
    #end
    #redirect_to anime_videos_show_url(video.anime_id), notice: 'Видео удалено'
  #end

  #def help
  #end

  #def extract_url
    #render text: VideoExtractor::UrlExtractor.new(params[:url]).extract
  #end

  #def viewed
    #video = AnimeVideo.find params[:id]
    #anime = Anime.find params[:anime_id]
    #user_rate = anime.rates.find_by_user_id current_user.id
    #UserRate.update(user_rate.id, episodes: video.episode) if user_rate

    #redirect_to anime_videos_show_url video.anime_id, video.episode + 1
  #end

  #def rate
    #UserRate.create_or_find(current_user.id, params[:id], 'Anime').save
    #render nothing: true
  #end


private
  #def video_params
    #params
      #.require(:anime_video)
      #.permit(:episode, :url, :anime_id, :source, :kind)
      #.merge(state: 'uploaded')
  #end

  #def find_or_create_author name
    #name = name.to_s.strip
    #AnimeVideoAuthor.where(name: name).first || AnimeVideoAuthor.create(name: name)
  #end
  def resource_id
    params[:anime_id]
  end

  def resource_klass
    Anime
  end

  def check_redirect
    unless AnimeOnlineDomain::valid_host? @anime, request
      return redirect_to anime_videos_show_url(@anime.id, domain: AnimeOnlineDomain::host(@anime), subdomain: false)
    end
  end

  def save_preferences
    if params[:video_id]
      if video = AnimeVideo.find_by(id: params[:video_id])
        cookies[:preference_kind] = video.kind
        cookies[:preference_hosting] = video.hosting
        cookies[:preference_author_id] = video.anime_video_author_id
      end
    end
  end
end
