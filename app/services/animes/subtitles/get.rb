class Animes::Subtitles::Get
  method_object :anime

  def call
    PgCache.read("anime_#{@anime.id}_subtitles") || {}
  end
end
