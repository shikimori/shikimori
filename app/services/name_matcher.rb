# матчер названий аниме и манги со сторонних сервисов с названиями на сайте
class NameMatcher
  attr_reader :cache

  ANIME_FIELDS = [:id, :name, :russian, :english, :synonyms, :status, :kind, :aired_on, :episodes, :rating, :censored]
  MANGA_FIELDS = [:id, :name, :russian, :english, :synonyms, :status,:kind, :aired_on, :chapters, :rating, :censored]

  BAD_NAMES = /\A(\d+|первыйсезон|второйсезон|третийсезон|сезонпервый|сезонвторой|сезонтретий|спецвыпуск\d+|firstseason|secondseason|thirdseason|anime|theanime|themovie|movie)\Z/

  delegate :fix, :multiply_phrases, :variants,
    :split_by_delimiters, :phrase_variants, to: :phraser

  # конструктор
  def initialize klass, ids=nil, services=[]
    # в каком порядке будем обходить кеш
    @match_order = [:predefined, :name, :alt, :alt2, :alt3, :russian]

    @klass = klass
    @ids = ids
    @services = services
    @cache = build_cache
    #@cache.each {|k,v| ap v.keys }
  end

  # поиск всех подходящих id аниме по переданным наваниям
  # возможные опции: year и episodes
  def matches names, options={}
    found = matching_groups(fix Array(names)).first ||
      matching_groups(variants(names, false)).first ||
      matching_groups(variants(names, true)).first

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
    variants(name).each do |variant|
      @match_order.each do |group|
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
      @match_order.each do |group|
        memo[group] ||= []
        memo[group] << @cache[group][variant] if @cache[group][variant]
      end
    end

    found_matches.select { |group, matches| matches.any? }
  end

  # рекурсивная замена фразы на альтернативы
  # медленнее второго варианта на 40%
  #def multiply_phrases phrases, from, to, nesting=1
    #raise 'infinite loop' if nesting > 50

    #multiplies = phrases.flat_map do |phrase|
      #replaced = phrase.sub(from, to).strip

      #if replaced != phrase
        #multiply_phrases [replaced], from, to, nesting+1
      #end
    #end

    #(phrases + multiplies.compact).uniq
  #end

  # заполнение кеша
  def build_cache
    cache = {
      name: {},
      alt: {},
      alt2: {},
      alt3: {},
      russian: {},
      predefined: predefined_matches
    }
    @services.each { |service| cache[service] = {} }

    datasource.each do |entry|
      names = {
        name: main_names(entry).compact,
        alt: alt_names(entry).compact,
        alt2: alt2_names(entry).compact,
        russian: russian_names(entry).compact
      }
      names.each {|k,v| v.map!(&:downcase) }
      names[:alt3] = alt3_names(entry, names[:alt2])

      names.each {|k,v| names[k] = (v + v.map {|name| fix name }).uniq }

      names.each do |group,names|
        names.each do |name|
          cache[group][name] ||= []
          cache[group][name] << entry
        end
      end

      # идентификаторы привязанных сервисов
      entry
        .links
        .select {|v| @services.include?(v.service.to_sym) }
        .each {|link| cache[link.service.to_sym][link.identifier] = entry } if @services.present?

    end

    cache
  end

  def main_names entry
    names = [entry.name, "#{entry.name} #{entry.kind}"]
    aired_on = ["#{entry.name} #{entry.aired_on.year}"] if entry.aired_on

    names + (aired_on || [])
  end

  def alt_names entry
    synonyms = entry.synonyms.map {|v| "#{v} #{entry.kind}" } + (entry.aired_on ? entry.synonyms.map {|v| "#{v} #{entry.aired_on.year}" } : []) if entry.synonyms
    english = entry.english.map {|v| "#{v} #{entry.kind}" }  + (entry.aired_on ? entry.english.map {|v| "#{v} #{entry.aired_on.year}" } : []) if entry.english

    (synonyms || []) + (english || [])
  end

  def alt2_names entry
    [entry.name] + (entry.synonyms ? entry.synonyms : []) + (entry.english ? entry.english : [])
  end

  def alt3_names entry, alt1_names
    names = alt1_names.map {|name| phrase_variants name, entry.kind }.compact.flatten
    (
      names +
      names.map {|v| v.gsub('!', '') } +
      alt1_names.select {|v| v =~ /!/ }.map {|v| v.gsub('!', '') }
    ).uniq
  end

  def russian_names entry
    names = [entry.russian, fix(entry.russian), phrase_variants(entry.russian)]
      .flatten
      .compact
      .map(&:downcase)

    (names + names.map {|v| v.gsub('!', '') }).uniq
  end

  def datasource
    ds = @klass
    ds = ds.where id: @ids if @ids.present?
    ds = ds.includes(:links) if @services.present?

    ds
      .select(db_fields)
      .sort_by {|v| v.kind == 'tv' ? 0 : 1 } # выборку сортируем, чтобы TV было последним и перезатировало всё остальное
  end

  def predefined_matches
    config = NameMatches::Config.instance.predefined_names(@klass)

    entries_by_id = @klass
      .where(id: config.values)
      .select(db_fields)
      .each_with_object({}) {|v,memo| memo[v.id] = v }

    config.each_with_object({}) do |(k,v),memo|
      memo[fix k] = [entries_by_id[v]]
    end
  end

  def db_fields
    @klass == Anime ? ANIME_FIELDS : MANGA_FIELDS
  end

  def phraser
    @phraser ||= NameMatches::Phraser.new
  end
end
