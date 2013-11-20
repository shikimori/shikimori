class AnimeOnline::AnimeVideosController < ApplicationController
  layout 'anime_online'

  def index
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
end
