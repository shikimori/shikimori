class Animes::Subtitles::Set
  method_object :anime, :value

  def call
    PgCache.write "anime_#{@anime.id}_subtitles", @value
  end
end
