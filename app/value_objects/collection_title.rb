class CollectionTitle
  include Translation
  prepend ActiveCacher.instance

  instance_cache :types_text
  instance_cache :fancy?

  def initialize klass:, user:, season:, type:, status:, genres:, studios:, publishers:
    @klass = klass
    @user = user

    @seasons = (season || '').split(',')
    @types = (type || '').gsub(/-/, ' ').split(',').select { |v| !v.starts_with? '!' }
    @statuses = (status || '').split(',')
    @genres = Array genres
    @studios = Array studios
    @publishers = Array publishers
  end

  def title
    if fancy?
      fancy_title
    else
      composite_title
    end
  end

  def fancy_title
    if genre?
      genre_text true
    elsif season?
      season_text true
    ...
    end
  end

  def genre_text
    if is_fancy
      'Романтические аниме про любовь'
    else
      "жанра(ов) #{localized_name(genre).to_sentence}"
    end
  end

  def composite_title
    title = [
      statuses_text,
      types_text,
      studios_text,
      publishers_text,
      genres_text,
      seasons_text
    ].compact.join(' ')

    if title == Anime.model_name.human && user.nil?
      i18n_i('Best_anime', :other)
    else
      title
    end
  end

private

  attr_reader :klass, :user
  attr_reader :seasons, :types, :statuses, :genres, :studios, :publishers

  def fancy?
    (seasons + types + statuses + genres + studios + publishers).one?
  end

  def statuses_text
    return if statuses.empty?

    statuses
      .map { |status| i18n_t "status.#{klass.name.downcase}.#{status}"}
      .to_sentence
  end

  def types_text
    return klass.model_name.human if types.empty?

    types.map do |type|
      I18n.t "enumerize.#{klass.name.downcase}.kind.plural.#{type}",
        default: klass.model_name.human
    end.to_sentence
  end

  #def genre_text
    #return unless genres.one?
    #genres.first.format_for_title types_text, rus_var(types_text)
  #end

  def genres_text
    return unless genres.many?

    list = genres
      .map { |genre| UsersHelper.localized_name genre, user }
      .to_sentence
    "#{i18n_i 'genre', genres.count, :genitive} #{list}"
  end

  def studios_text
    return if studios.empty?

    list = studios.map(&:name).to_sentence
    "#{i18n_i 'studio', studios.count, :genitive} #{list}"
  end

  def publishers_text
    return if publishers.empty?

    publishers_list = publishers.map(&:name).to_sentence
    "#{i18n_i 'publisher', publishers.count, :genitive} #{publishers_list}"
  end

  def seasons_text
    return unless seasons.one?
    "#{AniMangaSeason.title_for seasons.first, klass}"
  end

  # TODO refactor or remove
  #def rus_var types_text
    #klass == Anime ||
      #(
        #types &&
        #(
          #types.include?(',') ||
          #types.include?('novel')
        #)
      #)
  #end
end
