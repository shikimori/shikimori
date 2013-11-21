class AnimeOnline::AnimeVideosController < ApplicationController
  layout 'anime_online'

  def index
    #@anime_list = Anime.paginate page: page, per_page: per_page
    @anime_list = Anime
      .joins(:anime_videos)
      .select('distinct animes.*')
      .paginate page: page, per_page: per_page

    # в один запрос will_paginate с distinct-ом total_pages - возвращает слишком много / Kalinichev /
    @anime_ids = AnimeVideo
      .select('distinct anime_id')
      .paginate page: page, per_page: per_page
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
