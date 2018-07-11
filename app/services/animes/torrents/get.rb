class Animes::Torrents::Get
  method_object :anime

  def call
    BigDataCache.read("anime_#{@anime.id}_torrents") || []
  end
end
