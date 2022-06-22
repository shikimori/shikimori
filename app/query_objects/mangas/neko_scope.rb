class Mangas::NekoScope
  method_object

  def call
    Manga
      .where.not(status: :anons)
      .order(:id)
  end
end
