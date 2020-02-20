class LicensorsRepository
  include Singleton

  def anime
    @anime ||= Anime.where.not(licensor: '').distinct.pluck(:licensor).sort
  end

  def manga
    @manga ||= Manga.where.not(licensor: '').distinct.pluck(:licensor).sort
  end

  def ranobe
    @ranobe ||= Ranobe.where.not(licensor: '').distinct.pluck(:licensor).sort
  end
end
