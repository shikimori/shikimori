class Animes::NekoScope
  method_object

  def call
    Anime.order(:id)
  end
end
