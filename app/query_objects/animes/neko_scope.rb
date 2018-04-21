class Animes::NekoScope
  method_object

  def call
    Anime.where.not(kind: %i[special music]).order(:id)
  end
end
