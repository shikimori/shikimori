class Animes::Torrents::Get
  method_object :anime

  def call
    PgCache.read("anime_#{@anime.id}_torrents") || []
  end
end
