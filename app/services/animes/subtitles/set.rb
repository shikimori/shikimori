class Animes::Subtitles::Set
  method_object :anime, :value

  def call
    BigDataCache.write "anime_#{@anime.id}_subtitles", @value
  end
end
