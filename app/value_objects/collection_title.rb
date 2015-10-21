class CollectionTitle
  include Translation
  prepend ActiveCacher.instance

  instance_cache :type_text

  def initialize klass:, user:, season:, type:, genres:, studios:, publishers:
    @klass = klass
    @user = user
    @seasons = (season || '').split(',')
    @types = (type || '').gsub(/-/, ' ').split(',').select { |v| !v.starts_with? '!' }
    @genres = genres.to_a
    @studios = studios.to_a
    @publishers = publishers.to_a
  end

  def title
    title = "
      #{genre_text || type_text}
      #{studios_text}
      #{publishers_text}
      #{genre_text}
      #{seasons_text}
    "

    if title == Anime.model_name.human
      i18n_i('best_anime', :other)
    else
      title
    end
  end

private

  attr_reader :klass, :user, :seasons, :types, :genres, :studios, :publishers

  def type_text
    return klass.model_name.human if types.empty?

    types.map do |type|
      I18n.t "enumerize.#{klass.name.downcase}.kind.plural.#{type}",
        default: klass.model_name.human
    end.to_sentence
  end

  def genre_text
    return unless genres.one?
    genres.first.format_for_title type_text, rus_var(type_text)
  end

  def genres_text
    return if genres.one?

    list = genres
      .map { |genre| UsersHelper.localized_name genre, user }
      .to_sentence
    " #{i18n_i 'genre', genres.count, :genitive} #{list}"
  end

  def studios_text
    return if studios.empty?

    studios_list = studios.map(&:name).to_sentence
    " #{i18n_i 'studio', studios.count, :genitive} #{studios_list}"
  end

  def publishers_text
    return if publishers.empty?

    publishers_list = publishers.map(&:name).to_sentence
    " #{i18n_i 'publisher', publishers.count, :genitive} #{publishers_list}"
  end

  def seasons_text
    return if seasons.many?
    " #{AniMangaSeason.title_for seasons.first, klass}"
  end

  # TODO refactor or remove
  def rus_var type_text
    klass == Anime ||
      (
        types &&
        (
          types.include?(',') ||
          types.include?('novel')
        )
      )
  end
end
