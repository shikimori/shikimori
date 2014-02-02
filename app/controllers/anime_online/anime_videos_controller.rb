#TODO разделить аниме для play и xplay в #index, #show, #search
class AnimeOnline::AnimeVideosController < ApplicationController
  layout 'anime_online'

  after_filter :save_preferences, only: :show

  def index
    anime_query = AnimeVideosQuery.new AnimeOnlineDomain::adult_host?(request), params
    @anime_ids = anime_query.search.order.page.fetch_ids
    @anime_list = AnimeVideoDecorator.decorate_collection anime_query.search.order.page.fetch_entries
  end

  def search
    search = params[:search].to_s.strip
    if search.blank?
      redirect_to root_url
    else
      redirect_to anime_videos_url search: params[:search], page: 1
    end
  end

  def show
    unless params[:search].blank?
      redirect_to anime_videos_url search: params[:search]
      return
    end

    @anime = AnimeVideoDecorator.new(
      Anime
        .includes(:anime_videos, :genres)
        .find params[:id])

    unless AnimeOnlineDomain::valid_host? @anime, request
      redirect_to anime_videos_show_url @anime.id, domain: AnimeOnlineDomain::host(@anime), subdomain: false
      return
    end

    raise ActionController::RoutingError.new 'Not Found' if @anime.anime_videos.blank?

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
    @video = AnimeVideo.new video_params
    @video.author = find_or_create_author params[:anime_video][:author].to_s.strip
    if @video.save
      AnimeVideoReport.create! user: current_user, anime_video: @video, kind: :uploaded
      redirect_to anime_videos_show_url @video.anime.id, @video.episode, @video.id
    else
      render :new
    end
  end

  def help
  end

  def report
    user = user_signed_in? ? current_user : User.find(User::GuestID)
    anime_video = AnimeVideo.find params[:id]
    unless AnimeVideoReport.where(kind: params[:kind], anime_video_id: params[:id]).first
      AnimeVideoReport.create! user: user, anime_video: anime_video, kind: params[:kind], user_agent: request.user_agent
    end
    render nothing: true
  end

private
  def video_params
    #.merge(uploader_id: current_user.id)
    params
      .require(:anime_video)
      .permit(:episode, :url, :anime_id, :source, :kind)
      .merge(state: 'uploaded')
  end

  def find_or_create_author name
    AnimeVideoAuthor.where(name: name).first || AnimeVideoAuthor.new(name: name)
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
