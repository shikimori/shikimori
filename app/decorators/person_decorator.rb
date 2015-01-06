class PersonDecorator < DbEntryDecorator
  decorates_finders

  instance_cache :website, :all_roles, :groupped_roles, :roles_names, :works, :best_works
  instance_cache :producer_favoured?, :mangaka_favoured?, :person_favoured?, :seyu_favoured?
  instance_cache :seyu_counts, :composer_counts, :producer_counts, :mangaka_counts

  ROLES = {
    seyu: ['Japanese', 'English', 'Italian', 'Hungarian', 'German', 'Brazilian', 'French', 'Spanish', 'Korean'],
    composer: ['Music'],
    producer: ['Chief Producer', 'Producer', 'Director', 'Episode Director'],
    mangaka: ['Original Creator', 'Story & Art', 'Story']
  }

  def credentials?
    japanese.present? || object.name.present?
  end

  def url
    h.person_url object
  end

  def website_host
    begin
      URI.parse(website).host
    rescue
    end
  end

  def website
    if object.website.present?
      'http://%s' % object.website.sub(/^(https?:\/\/)?/, '')
    else
      nil
    end
  end

  def flatten_roles
    object.person_roles
      .pluck(:role)
      .map {|v| v.split(/, */) }
      .flatten
  end

  def groupped_roles
    flatten_roles.each_with_object({}) do |role, memo|
      role_name = I18n.t("Role.#{role}")
      memo[role_name] ||= 0
      memo[role_name] += 1
    end.sort_by {|v| [-v.second, v.first] }
  end

  def favoured
    FavouritesQuery.new.favoured_by object, 12
  end

  def works
    all_roles
      .select {|v| v.anime || v.manga }
      .map {|v| RoleEntry.new((v.anime || v.manga).decorate, v.role) }
      .sort_by do |v|
        if h.params[:order_by] == 'date'
          v.aired_on || v.released_on || DateTime.now - 99.years
        else
          v.score && v.score < 9.9 ? v.score : -999
        end
      end.reverse
  end

  def best_works
    anime_ids = animes.pluck(:id)
    manga_ids = mangas.pluck(:id)

    sorted_works = FavouritesQuery.new
      .top_favourite([Anime.name, Manga.name], 6)
      .where("(linked_type=? and linked_id in (?)) or (linked_type=? and linked_id in (?))",
        Anime.name, anime_ids, Manga.name, manga_ids)
      .map {|v| [v.linked_id, v.linked_type] }

    drop_index = 0
    while sorted_works.size < 6 && works.size > drop_index
      work = works.drop(drop_index).first
      mapped_work = [work.id, work.object.class.name]
      sorted_works.push mapped_work unless sorted_works.include?(mapped_work)
      drop_index += 1
    end

    selected_anime_ids = sorted_works.select {|v| v[1] == Anime.name }.map(&:first)
    selected_manga_ids = sorted_works.select {|v| v[1] == Manga.name }.map(&:first)
    (
      works.select {|v| v.anime? && selected_anime_ids.include?(v.id) } +
        works.select {|v| v.manga? && selected_manga_ids.include?(v.id) }
    ).sort_by {|v| sorted_works.index [v.id, v.object.class.name] }
  end

  def job_title
    #if role?(:producer) && role?(:mangaka)
      #'Режиссёр аниме и автор манги'
    if main_role?(:producer)
      'Режиссёр аниме'
    elsif main_role?(:mangaka)
      'Автор манги'
    elsif main_role?(:seyu)
      'Сэйю'
    elsif main_role?(:composer)
      'Композитор'
    elsif has_anime? && has_manga?
      'Участник аниме и манга проектов'
    elsif has_anime?
      'Участник аниме проектов'
    elsif has_manga?
      'Участник манга проектов'
    end
  end

  def occupation
    if has_anime? && has_manga?
      'Аниме и манга'
    elsif has_anime?
      'Аниме'
    elsif has_manga?
      'Манга'
    else
      'Проекты'
    end
  end

  def role? role
    !roles_counts(role).zero?
  end

  def main_role? role
    other_roles = ROLES.keys
      .select {|v| v != role }
      .map {|v| roles_counts v }

    roles_counts(role) > other_roles.max
  end

  def seyu_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Seyu)
  end

  def producer_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Producer)
  end

  def mangaka_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Mangaka)
  end

  def person_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Person)
  end

  def url
    h.person_url object
  end

  # тип элемента для schema.org
  def itemtype
    'http://schema.org/Person'
  end

private
  def has_anime?
    all_roles.any? {|v| !v.anime_id.nil? }
  end

  def has_manga?
    all_roles.any? {|v| !v.manga_id.nil? }
  end

  def all_roles
    object.person_roles.includes(:anime).includes(:manga).to_a
  end

  def roles_names
    groupped_roles.map {|k,v| k }
  end

  def roles_counts role
    flatten_roles.count {|v| ROLES[role].include? v }
  end
end
