class Animes::Subtitles::Set
  method_object :anime, :subtitles

  def call
    BigDataCache.write "anime_#{@anime.id}_subtitles", subtitles
  end
end
