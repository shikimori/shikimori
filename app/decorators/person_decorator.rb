class PersonDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def with_credentials?
    japanese.present? || object.name.present?
  end

  def url
    h.person_url object
  end

  def website
    @website ||= if object.website.present?
      'http://%s' % object.website.sub(/^(http:\/\/)?/, '')
    else
      nil
    end
  end

  def groupped_roles
    @groupped_roles ||= begin
      person_roles = object.person_roles
        .group(:role)
        .select('role, count(*) as times')

      roles = {}
      person_roles.each do |person_role|
        person_role.role.split(',').each do |v|
          v = process_role v
          if roles.keys.include?(v)
            roles[v] += person_role.times.to_i
          else
            roles[v] = person_role.times.to_i
          end
        end
      end
      roles = roles.sort do |lhs,rhs|
        if lhs[1] < rhs[1]
          1
        elsif lhs[1] > rhs[1]
          -1
        else
          begin
            I18n.t("Role.#{lhs[0]}") <=> I18n.t("Role.#{rhs[0]}")
          rescue
            0
          end
        end
      end
    end
  end

  def favoured
    @favoured ||= FavouritesQuery.new(object, 12).fetch
  end

  def works
    @works ||= begin
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
    @is_seyu ||= (roles_names & [
      'Japanese',
      'English'
    ]).any?
  end

  def composer?
    @is_composer ||= (roles_names & [
      'Music'
    ]).any?
  end

  def seyu_favoured?
    h.user_signed_in? && h.current_user.favoured?(object, Favourite::Seyu)
  end

  def producer?
    @is_producer ||= (roles_names & [
      'Chief Producer',
      'Producer',
      'Director',
      'Episode Director'
    ]).any?
  end

  def producer_favoured?
    @producer_favoured ||= h.user_signed_in? && h.current_user.favoured?(object, Favourite::Producer)
  end

  def mangaka?
    @is_mangaka ||= (roles_names & [
      'Original Creator',
      'Story & Art',
      'Story'
    ]).any?
  end

  def mangaka_favoured?
    @mangaka_favoured ||= h.user_signed_in? && h.current_user.favoured?(object, Favourite::Mangaka)
  end

  def person_favoured?
    @person_favoured ||= h.user_signed_in? && h.current_user.favoured?(object, Favourite::Person)
  end

private
  def process_role(role)
    role.strip
  end

  def has_anime?
    all_roles.any? {|v| !v.anime_id.nil? }
  end

  def has_manga?
    all_roles.any? {|v| !v.manga_id.nil? }
  end

  def all_roles
    @all_roles ||= object.person_roles.includes(:anime).includes(:manga).to_a
  end

  def roles_names
    @roles_names ||= groupped_roles.map {|k,v| k }
  end
end
