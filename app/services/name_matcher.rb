# матчер названий аниме и манги со сторонних сервисов с названиями на сайте
class NameMatcher
  attr_reader :cache

  COMMON_FIELDS = [:id, :name, :russian, :english, :synonyms, :japanese,
    :status, :kind, :aired_on, :rating, :censored]
  ANIME_FIELDS = COMMON_FIELDS + [:episodes]
  MANGA_FIELDS = COMMON_FIELDS + [:chapters]

  # конструктор
  def initialize klass, ids=nil, services=[]
    @klass = klass
    @ids = ids
    @services = services

    @namer ||= NameMatches::Namer.instance
    @cleaner ||= NameMatches::Cleaner.instance
    @phraser ||= NameMatches::Phraser.instance
    @config ||= NameMatches::Config.instance

    @cache = build_cache
    #@cache.each {|k,v| ap v.keys }
  end

  # поиск всех подходящих id аниме по переданным наваниям
  # возможные опции: year и episodes
  def matches names, options={}
    phrases = cleanup Array(names)

    variants = [
      finalize(phrases),
      finalize(@phraser.variate(phrases, do_splits: false)),
      finalize(@phraser.variate(phrases, do_splits: true))
    ]

    found = matching_groups(variants.first).first ||
      matching_groups(variants.second).first ||
      matching_groups(variants.third).first

    if found
      entries = found.second.flatten.compact.uniq
      entries.one? ? entries : AmbiguousMatcher.new(entries, options).resolve
    else
      []
    end
  end

  # поиск id аниме по переданному наванию
  def match name
    ActiveSupport::Deprecation.warn "use .matches instead.", caller
    @phraser.variate(name).each do |variant|
      NameMatch::GROUPS.each do |group|
        ids = @cache[group][variant]
        return ids.first if ids
      end
    end

    nil
  end

  # выборка id аниме по однозначному совпадению по простым алгоритмам поиска AniMangaQuery
  def fetch name
    ActiveSupport::Deprecation.warn "use .matches instead.", caller
    results = AniMangaQuery.new(@klass, search: name).fetch.to_a

    if results.one?
      results.first

    elsif results.any?
      puts "ambiguous result: \"#{results.map(&:name).join("\", \"")}\""
      nil
    else
      nil
    end
  end

  # поиск id аниме по идентификатору связанного сайта
  def by_link identifier, service
    @cache[service][identifier]
  end

  def add_link entry, identifier, service
    @cache[service][identifier] = entry
  end

private

  def matching_groups fixed_names
    found_matches = fixed_names.each_with_object({}) do |variant,memo|
      NameMatch::GROUPS.each do |group|
        memo[group] ||= []
        memo[group] << @cache[group][variant] if @cache[group][variant]
      end
    end

    found_matches.select { |group, matches| matches.any? }
  end

  # заполнение кеша
  def build_cache
    cache = {
      name: {},
      alt: {},
      alt2: {},
      alt3: {},
      russian: {},
      russian_alt: {},
      predefined: {}
    }
    @services.each { |service| cache[service] = {} }

    datasource.each do |entry|
      names = {
        name: compact(@namer.name entry),
        alt: compact(@namer.alt entry),
        alt2: compact(@namer.alt2 entry),
        alt3: compact(@namer.alt3 entry),
        russian: compact(@namer.russian entry),
        russian_alt: compact(@namer.russian_alt entry),
        predefined: compact(@namer.predefined entry)
      }

      names.each do |group,names|
        names.each do |name|
          cache[group][name] ||= []
          cache[group][name] << entry
        end
      end

      # идентификаторы привязанных сервисов
      entry
        .links
        .select { |v| @services.include?(v.service.to_sym) }
        .each { |link| cache[link.service.to_sym][link.identifier] = entry } if @services.present?
    end

    cache
  end

  def datasource
    ds = @klass
    ds = ds.where id: @ids if @ids.present?
    ds = ds.includes(:links) if @services.present?

    ds
      .select(db_fields)
      .sort_by {|v| v.kind == 'tv' ? 0 : 1 } # выборку сортируем, чтобы TV было последним и перезатировало всё остальное
  end

  def cleanup names
    names.map { |name| @cleaner.cleanup name }.uniq
  end

  def compact names
    names.map { |name| @cleaner.compact name }.uniq
  end

  def finalize names
    names.map { |name| @cleaner.finalize name }.uniq
  end

  def db_fields
    @klass == Anime ? ANIME_FIELDS : MANGA_FIELDS
  end
end
