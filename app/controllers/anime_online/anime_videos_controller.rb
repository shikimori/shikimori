class AnimeOnline::AnimeVideosController < ApplicationController
  def show
    @anime = Anime.includes(:anime_videos).find params[:id]

    # for test
    #@anime.anime_videos << AnimeVideo.new(url: 'http://my.mail.ru/video/mail/bel_comp1/14985/15777.html#video=/mail/bel_comp1/14985/15777')
  end
end
