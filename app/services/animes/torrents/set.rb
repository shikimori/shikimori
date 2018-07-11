class Animes::Torrents::Set
  method_object :anime, :value

  def call
    BigDataCache.write "anime_#{@anime.id}_torrents", @value
  end
end
