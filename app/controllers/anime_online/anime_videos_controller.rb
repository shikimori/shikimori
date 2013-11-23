class AnimeOnline::AnimeVideosController < ApplicationController
  layout 'anime_online'

  def index
    @anime_ids = AnimeVideo
      .select('distinct anime_id')
      .paginate page: page, per_page: per_page

    @anime_list = AnimeVideoPreviewDecorator.decorate_collection Anime.where(id: @anime_ids.map(&:anime_id))
  end

  def show
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
end
