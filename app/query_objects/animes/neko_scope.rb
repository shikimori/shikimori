class Animes::NekoScope
  method_object

  ALLOWED_IDS = [1]

  def call
    Anime
      .where.not(kind: %i[special music])
      .or(Anime.where(id: ALLOWED_IDS))
      .order(:id)
  end
end
