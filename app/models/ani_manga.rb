module AniManga
  OngoingToReleasedDays = 2

  def self.included(base)
    base.extend(ClassMethods)

    base.before_save -> {
      self.russian = CGI::escapeHTML self.russian if self.changes['russian']
    }
  end

  # при изменении description будем менять и description_html
  def description=(text)
    self[:description] = text
    self.description_html = BbCodeService.instance.format_description(text, self)
  end

  def to_param
    #HTMLEntities.new.decode( ☆ ß
    "%d-%s" % [id, name.gsub(/&#szlig;|ß/, 'ss')
                       .gsub(/&#\d{4};/, '-')
                       .gsub('Ä', 'A')
                       .gsub(/[^A-z0-9]+/, '-')
                       .gsub(/^-|-$/, '')
              ]
  end

  def year
    aired_at ? aired_at.year : nil
  end

  # костыль от миграеции на 1.9.3
  def japanese
    self[:japanese] ? self[:japanese].map {|v| v.force_encoding('utf-8') } : []
  end

  def english
    self[:english] || []
  end

  # временный костыль после миграции на 1.9.3
  def synonyms
    self[:synonyms] ? self[:synonyms].map {|v| v.encode('utf-8', :undef => :replace, :invalid => :replace, :replace => '') } : []
  end

  def anons?
    [AniMangaStatus::Anons, AniMangaStatus::Upcoming].include?(status)
  end

  def short_name
    name.gsub(/:.*|'$/, '')
  end

  def description
    desc = self[:description] || self[:description_mal] || ''
    if desc.blank?
      self.class == Anime ? "У этого аниме пока ещё нет описания." : "У этой манги пока ещё нет описания."
    else
      desc.html_safe
    end
  end

  def russian
    self[:russian] ? self[:russian].gsub(/\.? *\((?:С|с)езон .*\)$|\.? *\((?:С|с)езон .*\)$|\.? *\(.* (?:С|с)езон\)$|\.? *(\[|\()(?:TV|ТВ|OVA|ONA|ОВА|Movie).*(\]|\))$|(?: - )?\(?(?:Ф|ф)ильм[^,]*?\)?$/i, '').strip : nil
  end

  # создание AniMangaComment для элемента сразу после создания
  def create_thread
    AniMangaComment.create! linked: self, generated: true, title: name
  end

  # при сохранении аниме обновление его CommentEntry
  def sync_thread
    if changes["name"]
      thread.class.record_timestamps = false
      thread.save
      thread.class.record_timestamps = true
    end
  end

  def ongoing?(ignore_excludes=false)
    ((aired_at != nil && aired_at < (Date.today - AniManga::OngoingToReleasedDays.days) && [AniMangaStatus::Anons, AniMangaStatus::Upcoming].include?(status)) ||
     (aired_at != nil && [AniMangaStatus::Ongoing, AniMangaStatus::Publishing].include?(status))) &&
    !([AniMangaStatus::Anons, AniMangaStatus::Upcoming].include?(status) && aired_at && aired_at.year == Date.today.year && aired_at.month == 1 && aired_at.day == 1) &&
    !(aired_at != nil && released_at != nil && aired_at < (Date.today - AniManga::OngoingToReleasedDays.days) && released_at < (Date.today - AniManga::OngoingToReleasedDays.days)) &&
    (!ignore_excludes || !self.class::EXCLUDED_ONGOINGS.include?(id))
  end

  # если жанров слишком много, то оставляем только 6 основных
  def main_genres
    all_genres = self.genres.sort_by {|v| Genre::LongNameGenres.include?(v.english) ? 0 : v.id }
    return all_genres if self.genres.size <= 5
    selected_genres = self.genres.select {|v| v.main? }
    all_genres.each do |genre|
      break if selected_genres.size > 5
      selected_genres << genre unless selected_genres.include? genre
    end
    selected_genres.sort_by {|v| Genre::LongNameGenres.include?(v.english) ? 0 : v.id }
  end

  # из списка студий/издателей аниме возвращает единственного настоящего
  ['studios', 'publishers'].each do |kind|
    define_method "real_#{kind}" do
      return [] if self.send(kind).empty?
      return self.send(kind).map {|v| v.real } if self.send(kind).size == 1
      @real_st_pub_cache ||= self.send(kind).map {|v| v.real }.select {|v| v.real? }
      @real_st_pub_cache.empty? ? [self.send(kind).first.real] : @real_st_pub_cache
    end
  end

  # тип элемента для schema.org
  def itemtype
    if kind == 'Movie'
      'http://schema.org/Movie'
    elsif kind == 'TV'
      'http://schema.org/TVSeries'
    else
      'http://schema.org/CreativeWork'
    end
  end

  # есть ли оценка?
  def with_score?
    score != 0.0 && score < 9.9
  end

  def rus_var(types)
    self.class.rus_var(self.class, types)
  end

  module ClassMethods
    def title_for(season, type, genres, studios, publishers)
      types = type ? type.gsub(/-/, ' ').split(',').select {|v| !v.starts_with? '!' } : nil

      type_name = type && types.any? ?
          types.map {|v| I18n.t("#{self.name}.Full.#{v}", default: self.name) }
               .join(types.count == 2 ? ' и ' : ', ') :
          I18n.t("Name.#{self.name}", default: self.name)

      genre_name = !genres.nil? && genres.count == 1 ? genres.first.format_for_title(type_name, self.rus_var(self, type_name)) : nil

      title = "%s%s%s%s%s" % [
          genre_name || type_name,
          studios.nil? || studios.empty? ? "" : (studios.count > 1 ? " студий " : " студии ") + studios.map(&:name).join(studios.count == 2 ? ' и ' : ', '),
          publishers.nil? || publishers.empty? ? "" : (publishers.count > 1 ? " издателей " : " издателя ") + publishers.map(&:name).join(publishers.count == 2 ? ' и ' : ', '),
          genres.nil? || genres.empty? || !genre_name.nil? ? "" : " жанров " + genres.map(&:russian).join(genres.count == 2 ? ' и ' : ', '),
          !season.blank? && !season.include?(',') ? " #{AniMangaSeason.title_for(season, self)}" : ""
        ]

      title == 'Аниме' ? 'Лучшие аниме' : title
    end

    def keywords_for(season, type, genres, studios, publishers)
      keywords = []
      case type
        when 'TV'
          keywords << 'аниме сериалы'

        when 'Novel'
          keywords << 'визуальные новеллы'

        when 'Movie'
          keywords << 'полнометражные аниме'

        else
          keywords << (self == Anime ? 'аниме анимэ' : 'манга')
      end
      keywords << AniMangaSeason.title_for(season, self) if season
      if genres
        keywords << 'жанр'
        keywords << genres.map {|v| "#{v.english} #{v.russian}" }.join(' ')
      end
      if studios
        keywords << 'студия'
        keywords << studios.map(&:name).join(' ')
      end
      if publishers
        keywords << 'издатель'
        keywords << publishers.map(&:name).join(' ')
      end
      keywords << "список каталог база"

      keywords.join ' '
    end

    def description_for(season, type, genres, studios, publishers)
      type_text_prefix = rus_var(self, type) ? 'всех ' : 'всей  '
      type_text = case type
        when 'TV'
          'аниме сериалов'

        when 'TV-13'
          'аниме сериалов длительностью до 16 эпизодов'

        when 'TV-24'
          'аниме сериалов длительностью до 28 эпизодов'

        when 'TV-48'
          'аниме сериалов длительностью более 28 эпизодов'

        when 'Novel'
          'визуальных новелл'

        when 'Movie'
          'полнометражных аниме'

        else
          self == Anime ? 'аниме' : 'манги'
      end
      if genres
        if genres.length == 1
          type_text = Unicode.downcase(genres.first.format_for_title(type_text, nil)) 
        else
          type_text += ' жанров '+(genres.count == 2 ? genres.map(&:name).join(' и ') : genres.map(&:name).join(', '))
        end
      end

      prefix = ""
      postfix = " с фильтрацией по жанрам и датам"
      season_text = case season
        when 'ongoing'
          type_text_prefix = nil
          prefix = " онгоингов "
          ""

        when 'planned'
          type_text_prefix = nil
          prefix = (rus_var(self, type) ? " анонсированных " : " анонсированной ")
          ""

        when 'latest'
          prefix = rus_var(self, type) ? " недвано вышедших " : " недвано вышедшей "
          type_text_prefix = nil
          ""

        when /^([a-z]+)_(\d+)$/
          type_text_prefix = nil
          if self == Anime
            return [nil, AniMangaSeason.anime_season_title(season), postfix]
          else
            " #{AniMangaSeason.title_for(season, self)}"
          end

        when /^(\d+)$/
          type_text_prefix = nil
          year = $1.to_i
          if DateTime.now.year < year
            ", запланированных к показу в #{year} году, "
          elsif DateTime.now.year == year
#" #{year} года, #{self == Anime ? 'которые' : 'которая'} уже #{self == Anime ? 'вышли' : 'вышла'} или ещё только #{self == Anime ? 'выйдут' : 'выйдет'}, "
            " #{year} года, #{rus_var(self, type) ? 'которые' : 'которая'} уже #{rus_var(self, type) ? 'вышли' : 'вышла'} или ещё только #{rus_var(self, type) ? 'выйдут' : 'выйдет'}, "
          else
#", #{self == Anime ? 'вышедших' : 'вышедшей'} в #{year} году, "
            ", #{rus_var(self, type) ? 'вышедших' : 'вышедшей'} в #{year} году, "
          end

        else
          ""
      end

      studio_text = studios.nil? || studios.empty? ? nil : (studios.count > 1 ? " студий " : " студии ") + (studios.count == 2 ? studios.map(&:name).join(' и ') : studios.map(&:name).join(', '))
      publisher_text = publishers.nil? || publishers.empty? ? nil : (publishers.count > 1 ? " издателей " : " издателя ") + (publishers.count == 2 ? publishers.map(&:name).join(' и ') : publishers.map(&:name).join(', '))

      ["Список", "#{prefix}#{type_text_prefix}#{type_text}#{studio_text}#{publisher_text}#{season_text}", postfix]
    end

    def rus_var(klass, types)
      klass == Anime || (types && (types.include?(',') || types.include?('овел') || types.include?('ovel')))
    end
  end
end
