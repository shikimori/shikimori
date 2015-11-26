class Titles::AnimeKeywords
  include Translation

  attr_reader :klass, :season, :type, :genres, :studios, :publishers

  def initialize klass:, season:, type:, genres:, studios:, publishers:
    @klass = klass
    @season = season
    @type = type
    @genres = Array genres
    @studios = Array studios
    @publishers = Array publishers
  end

  def keywords
    keywords = []

    keywords << season_keywords
    keywords << type_keywords
    keywords << genre_keywords
    keywords << studio_keywords
    keywords << publisher_keywords
    keywords << other_keywords

    keywords.flatten.compact.join(' ').squeeze(' ')
  end

private

  def season_keywords
    return if season.blank?
    Titles::LocalizedSeasonText.new(self, season).title
  end

  def type_keywords
    case type
      when 'tv'
        i18n_t 'type.tv'
      when 'novel'
        i18n_t 'type.novel'
      when 'movie'
        i18n_t 'type.movie'
      else
        klass == Anime ? i18n_t('type.anime') : i18n_t('type.manga')
    end
  end

  def genre_keywords
    return if genres.blank?
    [i18n_i('genre'), genres.map { |v| "#{v.english} #{v.russian}" }.join(' ')]
  end

  def studio_keywords
    return if studios.blank?
    [i18n_i('studio'), studios.map(&:name).join(' ')]
  end

  def publisher_keywords
    return if publishers.blank?
    [i18n_i('publisher'), publishers.map(&:name).join(' ')]
  end

  def other_keywords
    i18n_t 'other'
  end
end
