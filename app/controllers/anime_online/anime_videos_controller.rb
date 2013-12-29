class AnimeOnline::AnimeVideosController < ApplicationController
  layout 'anime_online'

  after_filter :save_preferences, only: :show

  def index
    if Rails.env.production?
      raise ActionController::RoutingError.new 'Not Found'
    end

    if search.blank?
      @anime_ids = AnimeVideo
        .select('distinct anime_id')
        .paginate page: page, per_page: per_page
    else
      @anime_ids = AnimeVideo
        .select('distinct anime_id')
        .joins(:anime)
        .where('name like ? or russian like ?', "%#{search}%", "%#{search}%")
        .paginate page: page, per_page: per_page
    end

    @anime_list = AnimeVideoPreviewDecorator.decorate_collection Anime.where(id: @anime_ids.map(&:anime_id))
  end

  def show
    redirect_to anime_videos_url search: search  unless search.blank?

    @anime = AnimeVideoDecorator.new(Anime
        .includes(:anime_videos, :genres)
        .find params[:id])

    raise ActionController::RoutingError.new 'Not Found' if @anime.anime_videos.blank?

    unless @anime.episode_id > 1
      @reviews = Comment
        .includes(:user)
        .where(commentable_id: @anime.thread)
        .reviews.order('id desc').limit 10
    end
  end

  def complaint
    user = user_signed_in? ? current_user : User.find(User::GuestID)
    Complaint.new.from(user).send_message "#{anime_videos_show_url params[:id], params[:episode_id], params[:video_id]}", params[:video_id], params[:kind]
    render nothing: true
  end

private
  def per_page
    40
  end

  def page
    [params[:page].to_i, 1].max
  end

  def search
    params[:search]
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
