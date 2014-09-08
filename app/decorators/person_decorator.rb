class PersonDecorator < DbEntryDecorator
  decorates_finders

  instance_cache :website, :groupped_roles, :roles_names, :all_roles, :favoured, :works
  instance_cache :producer?, :mangaka?, :seuy?, :composer?
  instance_cache :producer_favoured?, :mangaka_favoured?, :person_favoured?, :seyu_favoured?

  def credentials?
    japanese.present? || object.name.present?
  end

  def url
    h.person_url object
  end

  def website
    if object.website.present?
      'http://%s' % object.website.sub(/^(http:\/\/)?/, '')
    else
      nil
    end
  end

  def groupped_roles
    person_roles = object.person_roles
      .group(:role)
      .select('role, count(*) as times')

    person_roles.each_with_object({}) do |person_role, memo|
      person_role.role.split(',').each do |v|
        role = I18n.t("Role.#{v.strip.split(/, */).first}")

        if memo.keys.include?(role)
          memo[role] += person_role.times.to_i
        else
          memo[role] = person_role.times.to_i
        end
      end
    end.sort_by(&:first)
  end

  def favoured
    FavouritesQuery.new.favoured_by object, 12
  end

  def works
    begin
      entries = all_roles.select {|v| v.anime || v.manga }.map do |v|
        {
          role: v.role,
          entry: v.anime || v.manga
        }
      end
      entries = if h.params[:sort] == 'time'
        entries.sort_by {|v| (v[:entry].aired_on || v[:entry].released_on || DateTime.now + 10.years).to_datetime.to_i * -1 }
      else
        entries.sort_by {|v| -(v[:entry].score || -999) }
      end
    end
  end

  def job_title
    if producer? && mangaka?
      'Режиссёр аниме и автор манги'
    elsif producer?
      'Режиссёр аниме'
    elsif mangaka?
      'Автор манги'
    elsif seyu?
      'Сэйю'
    elsif composer?
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
    end
  end

  def seyu?
    (roles_names & [
      'Japanese',
      'English'
    ]).any?
  end

  def composer?
    (roles_names & [
      'Music'
    ]).any?
  end

  def seyu_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Seyu)
  end

  def producer?
    (roles_names & [
      'Chief Producer',
      'Producer',
      'Director',
      'Episode Director'
    ]).any?
  end

  def producer_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Producer)
  end

  def mangaka?
    (roles_names & [
      'Original Creator',
      'Story & Art',
      'Story'
    ]).any?
  end

  def mangaka_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Mangaka)
  end

  def person_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Person)
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
end
