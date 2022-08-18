# TODO: refactor into view object
# :best_works, :best_roles - refactor to query objects
class PersonDecorator < DbEntryDecorator
  decorates_finders

  WORK_GROUP_SIZE = 5
  BEST_ROLES_SIZE = 6

  instance_cache :website,
    :flatten_roles, :all_roles, :grouped_roles, :roles_names,
    :works, :works_texts, :work_types, :character_works,
    :best_works, :best_roles,
    :producer_favoured?, :mangaka_favoured?, :person_favoured?, :seyu_favoured?,
    :seyu_counts, :composer_counts, :producer_counts, :mangaka_counts

  ROLES = {
    seyu: Person::SEYU_ROLES,
    composer: ['Music', 'Theme Song Composition'],
    producer: ['Chief Producer', 'Producer', 'Director', 'Episode Director'],
    mangaka: Person::MANGAKA_ROLES,
    vocalist: ['Theme Song Performance']
  }
  FIXED_CUSTOM_MAIN_ROLES = {
    2337 => { producer: true }
  }
  WORK_TYPES = [Anime, Manga, Ranobe]

  FAVOURITES_SQL = <<-SQL.squish
    (linked_type = '#{Anime.name}' and linked_id in (?)) or
    (linked_type in ('#{Manga.name}', '#{Ranobe.name}') and linked_id in (?))
  SQL

  def url
    h.person_url object
  end

  def website_html
    return if website_host.blank?

    h.link_to website_host, website_url, rel: 'nofollow', class: 'b-link'
  end

  def flatten_roles
    all_roles.flat_map(&:roles)
  end

  def grouped_roles
    flatten_roles.each_with_object({}) do |role, memo|
      role_name = I18n.t("role.#{role}", default: role)
      memo[role_name] ||= 0
      memo[role_name] += 1
    end.sort_by { |v| [-v.second, v.first] }
  end

  def favoured
    FavouritesQuery.new.favoured_by object, 12
  end

  def works
    all_roles
      .select(&:entry)
      .select { |role| h.params[:type] ? h.params[:type] == role.entry.class.name : true }
      .map { |role| RoleEntry.new(role.entry.decorate, role.roles) }
      .sort_by { |anime| sort_criteria anime }
      .reverse
  end

  def works_texts
    works
      .map do |entry|
        {
          linked_id: entry.id,
          linked_type: entry.object.class.base_class.name.downcase,
          text: entry.formatted_roles
        }
      end
  end

  def work_types
    all_roles
      .select(&:entry)
      .map { |role| role.entry.class }
      .uniq
      .sort_by { |klass| WORK_TYPES.index klass }
  end

  def best_works
    anime_ids = object.animes.pluck(:id)
    manga_ids = object.mangas.pluck(:id)

    sorted_works = FavouritesQuery.new
      .top_favourite([Anime.name, Manga.name], BEST_ROLES_SIZE)
      .where(FAVOURITES_SQL, anime_ids, manga_ids)
      .map { |v| [v.linked_id, v.linked_type] }

    drop_index = 0
    while sorted_works.size < BEST_ROLES_SIZE && works.size > drop_index
      work = works.drop(drop_index).first
      mapped_work = [work.id, work.object.class.name]
      sorted_works.push mapped_work unless sorted_works.include?(mapped_work)
      drop_index += 1
    end

    selected_anime_ids = sorted_works.select { |v| v[1] == Anime.name }.map(&:first)
    selected_manga_ids = sorted_works.select { |v| [Manga.name, Ranobe.name].include?(v[1]) }.map(&:first)
    (
      works.select { |v| v.anime? && selected_anime_ids.include?(v.id) } +
        works.select { |v| v.kinda_manga? && selected_manga_ids.include?(v.id) }
    ).sort_by { |v| sorted_works.index [v.id, v.object.class.name] }
  end

  def best_roles
    all_character_ids = characters.pluck(:id)
    character_ids = FavouritesQuery.new
      .top_favourite(Character, BEST_ROLES_SIZE)
      .where(linked_id: all_character_ids)
      .pluck(:linked_id)

    drop_index = 0
    while character_ids.size < BEST_ROLES_SIZE && character_works.size > drop_index
      character_id = character_works.drop(drop_index).first[:characters].first.id
      character_ids.push character_id unless character_ids.include? character_id
      drop_index += 1
    end

    Character
      .where(id: character_ids)
      .sort_by { |v| character_ids.index v.id }
  end

  def character_works
    @characters = []
    backindex = {}

    characters.includes(:animes).to_a.uniq.each do |char|
      entry = nil
      char.animes.each do |anime|
        if backindex.include?(anime.id)
          entry = backindex[anime.id]
          break
        end
      end

      if entry
        entry[:characters] << char
        char.animes.each do |anime|
          unless entry[:animes].include?(anime.id)
            entry[:animes][anime.id] = anime.decorate
            backindex[anime.id] = entry
          end
        end
      else
        top_franchise = char.animes.sort_by { |anime| sort_criteria anime }.last&.franchise
        franchise_animes = char.animes.select { |anime| anime.franchise == top_franchise }

        entry = {
          characters: [char.decorate],
          animes: franchise_animes.each_with_object({}) { |v, memo| memo[v.id] = v.decorate }
        }
        franchise_animes.each do |anime|
          backindex[anime.id] ||= entry
        end
        # ap entry[:animes]
        @characters << entry
      end
    end

    # для каждой группы оставляем только BEST_ROLES_SIZE в сумме аниме+персонажей
    @characters.each do |group|
      group[:characters] = group[:characters].take(3) if group[:characters].size > 3
      animes_limit = WORK_GROUP_SIZE - group[:characters].size
      group[:animes] = group[:animes]
        .map(&:second)
        .sort_by { |anime| sort_criteria anime }.reverse
        .take(animes_limit)
        .sort_by { |anime| anime.aired_on || anime.released_on || 30.years.ago }
    end

    @characters = @characters
      .sort_by do |character|
        if character[:animes].any?
          character[:animes].map { |anime| sort_criteria anime }.max
        elsif sort_by_date?
          30.years.ago
        else
          0
        end
      end
      .reverse
  end

  def job_title # rubocop:disable all
    key =
      if main_role? :producer
        'producer'
      elsif main_role? :mangaka
        'mangaka'
      elsif main_role? :composer
        'composer'
      elsif main_role? :vocalist
        'vocalist'
      elsif main_role? :seyu
        'seyu'
      else
        jobs = []

        jobs << 'anime' if anime_roles?
        jobs << 'manga' if manga_roles?
        # jobs << 'ranobe' if ranobe_roles?

        "#{jobs.join('_')}_projects_participant"
      end

    i18n_t "job_title.#{key}"
  end

  def occupation_key
    if anime_roles? && manga_roles?
      :anime_manga
    elsif anime_roles?
      :anime
    elsif manga_roles?
      :manga
    else
      :anime
      # disabled becase seyu has no works
      # raise ArgumentError, "Unknown occupation for #{self.class.name} #{to_param}"
    end
  end

  def role? role
    !roles_counts(role).zero?
  end

  def main_role? role
    return true if FIXED_CUSTOM_MAIN_ROLES.dig(object.id, role)

    other_roles = ROLES.keys
      .reject { |v| v == role }
      .map { |v| roles_counts v }

    roles_counts(role) >= other_roles.max && !roles_counts(role).zero?
  end

  def seyu_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Types::Favourite::Kind[:seyu])
  end

  def producer_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Types::Favourite::Kind[:producer])
  end

  def mangaka_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Types::Favourite::Kind[:mangaka])
  end

  def person_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Types::Favourite::Kind[:person])
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/Person'
  end

  def best_character
    character_ids = object.character_ids
    fav_character = FavouritesQuery.new
      .top_favourite([Character.name], 1)
      .where(
        'linked_type=? and linked_id in (?)',
        Character.name,
        character_ids
      )
      .first.linked_id

    Character.find(fav_character)
  end

  def anime_roles?
    all_roles.any? { |v| !v.anime_id.nil? }
  end

  def manga_roles?
    all_roles.any? { |v| !v.manga_id.nil? }
  end

private

  def all_roles
    if object.association_cached? :person_roles
      object.person_roles
    else
      object.person_roles.includes(:anime, :manga).to_a
    end
  end

  def roles_names
    grouped_roles.map(&:second)
  end

  def roles_counts role
    flatten_roles.count { |v| ROLES[role].include? v }
  end

  def website_host
    return if object.website.blank?

    Url.new(website_url).domain.to_s
  rescue URI::Error
  end

  def website_url
    return if object.website.blank?

    if object.website.match?(%r{^https?://})
      object.website
    else
      "http://#{object.website}"
    end
  end

  def sort_criteria anime
    if sort_by_date?
      anime.aired_on || anime.released_on || 30.years.ago
    else
      anime.score && anime.score < 9.9 ? anime.score : -999
    end
  end

  def sort_by_date?
    h.params[:order_by] == 'date'
  end
end
