class Titles::CollectionTitle
  include Translation
  prepend ActiveCacher.instance

  attr_reader :klass, :user, :seasons, :kinds, :statuses, :genres, :genres_v2, :studios, :publishers

  def initialize( # rubocop:disable Metrics/ParameterLists
    klass:,
    user:,
    season:,
    kind:,
    status:,
    genres_v2:,
    genres:,
    studios:,
    publishers:
  )
    @klass = klass
    @user = user

    @statuses = parse_param status
    @kinds = parse_param kind
    @studios = Array studios
    @publishers = Array publishers
    @genres = Array genres
    @genres_v2 = Array(genres_v2).reject(&:temporarily_posters_disabled?)
    @seasons = parse_param season
  end

  def title is_capitalized = true
    title = fancy? ? fancy_title : composite_title
    is_capitalized ? title.first_upcase : title.downcase
  end

  # 'отображена'? (вместо 'отображены')
  def manga_conjugation_variant?
    if statuses_text.present?
      title.match?(/#{Manga.model_name.human}/i)
    else # kinds_text
      !kinds.many? && title.match?(/#{Manga.model_name.human}/i)
    end
  end

private

  def fancy_title
    if genres_v2.present?
      genres_v2.first.title(user:, entry_type: @klass.name)
    elsif genres.present?
      genres.first.title(user:)
    else
      composite_title
    end
  end

  def composite_title
    title = [
      statuses_text || kinds_text,
      studios_text,
      publishers_text,
      genres_v2_text,
      genres_text,
      seasons_text
    ].compact.join(' ')

    if title == Anime.model_name.human && user.nil?
      i18n_i 'Best_anime', :other
    else
      title
    end
  end

  def fancy?
    (seasons + kinds + statuses + genres + genres_v2 + studios + publishers).one?
  end

  def statuses_text
    return if statuses.none?

    statuses
      .map { |status| status_text status }
      .to_sentence
  end

  def status_text status
    i18n_t(
      "status.#{klass.name.downcase}.#{kind_count_key}.#{status}",
      kind: kind_text(kinds.first)
    ).downcase
  end

  def kind_count_key
    if kinds.one?
      kinds.first == 'manga' ? :many_kinds : :one_kind
    else
      :many_kinds
    end
  end

  def kinds_text
    return klass.model_name.human if kinds.none?

    kinds
      .map { |kind| kind_text kind }
      .to_sentence
  end

  def studios_text
    return if studios.none?

    list = studios.map(&:name).to_sentence
    "#{i18n_i 'studio', studios.count, :genitive} #{list}"
  end

  def publishers_text
    return if publishers.none?

    publishers_list = publishers.map(&:name).to_sentence
    "#{i18n_i 'publisher', publishers.count, :genitive} #{publishers_list}"
  end

  def genres_v2_text
    return if genres_v2.none?

    list = genres_v2
      .map { |genre| UsersHelper.localized_name genre, user }
      .to_sentence
      .downcase

    of_genres = i18n_i 'genre', genres_v2.count, :genitive
    i18n_t 'of_genres', genres: of_genres, list:
  end

  def genres_text
    return if genres.none?

    list = genres
      .map { |genre| UsersHelper.localized_name genre, user }
      .to_sentence
      .downcase

    of_genres = i18n_i 'genre', genres.count, :genitive
    i18n_t 'of_genres', genres: of_genres, list:
  end

  def seasons_text
    return if seasons.none?

    seasons
      .map { |season| Titles::LocalizedSeasonText.new(klass, season).title }
      .to_sentence
  end

  def kind_text kind
    form = kinds.many? ? 'short' : 'long'

    text =
      if kind.present?
        i18n_t "kind.#{klass.name.downcase}.#{form}.#{kind}"
      else
        klass.model_name.human
      end

    text
      .downcase
      .gsub(/\bona\b/i, 'ONA')
      .gsub(/\bova\b/i, 'OVA')
      .gsub(/\btv\b/i, 'TV')
  end

  def parse_param param
    (param || '')
      .tr('-', ' ')
      .split(',')
      .reject { |v| v.starts_with? '!' }
  end
end
