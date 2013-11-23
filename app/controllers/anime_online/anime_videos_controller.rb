class AnimeOnline::AnimeVideosController < ApplicationController
  layout 'anime_online'

  def index
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
    unless search.blank?
      redirect_to anime_videos_url(search: search)
    end

    @anime = AnimeVideoDecorator.new(Anime
        .includes(:anime_videos, :genres)
        .find(params[:id]))

    @reviews = Comment.reviews
      .includes(:user)
      .where(commentable_id: @anime.id)
      .order('id desc').limit(5).to_a
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
end
