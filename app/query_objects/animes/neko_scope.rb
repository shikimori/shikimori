class Animes::NekoScope
  method_object

  def call
    Anime
      .where.not(status: :anons)
      .order(:id)
  end
end
