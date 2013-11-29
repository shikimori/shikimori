# матчер названий аниме и манги со сторонних сервисов с названиями на сайте
class NameMatcher
  FIELDS = [:id, :name, :russian, :english, :synonyms, :kind, :aired_at, :episodes]

  # конструктор
  def initialize klass, ids=nil, services=[]
    # в каком порядке будем обходить кеш
    @match_order = [:name, :alt, :alt2, :russian, :predefined]

    @klass = klass
    @ids = ids
    @services = services

    # хеш с названиями, по которому будем искать
    @cache = {
      name: {},
      alt: {},
      alt2: {},
      russian: {},
      predefined: predefined_matches
    }
    services.each {|service| @cache[service] = {} }

    build_cache
  end

  # поиск id аниме по переданному наванию
  def match name
    variants(name).each do |variant|
      @match_order.each do |group|
        ids = @cache[group][variant]
        return ids.first if ids
      end
    end

    nil
  end

  # поиск всех подходящих id аниме по переданным наваниям
  def matches names, options={}
    found = variants(names).each_with_object({}) do |variant,memo|
      @match_order.each do |group|
        memo[group] ||= []
        memo[group] << @cache[group][variant] if @cache[group][variant]
      end
    end.find do |group, matches|
      matches.any?
    end

    if found
      entries = found.second.flatten.compact.uniq
      entries.size == 1 ? entries : AmbiguousMatcher.new(entries, options).resolve
    else
      []
    end
  end

  # выборка id аниме по однозначному совпадению по простым алгоритмам поиска AniMangaQuery
  def fetch name
    results = AniMangaQuery.new(@klass, search: name).fetch

    if results.count == 1
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

private
  # фикс имени - вырезание из него всего, что можно
  def fix name
    (name || '')
      .downcase
      .force_encoding('utf-8')
      .gsub(/[-:,.~)(\/～"']/, '')
      .gsub(/`/, '\'')
      .gsub(/ /, '')
      .gsub(/☆|†|♪/, '')
      .strip
      #.gsub(/([A-z])0(\d)/, '\1\2')
  end

  # получение различных вариантов написания фразы
  def phrase_variants name, kind=nil
    return [] if name.nil?

    phrases = [name]

    phrases.concat split_by_delimiters(name, kind)

    # альтернативные названия в скобках
    phrases = phrases + phrases
      .select {|v| v =~ /[\[\(].{5}.*?[\]\)]/ }
      .map {|v| v.split(/[\(\)\[\]]/).map(&:strip) }
      .flatten

    # перестановки
    phrases = phrases + phrases
      .select {|v| v =~ /-/ }
      .map {|v| v.split(/-/).map(&:strip).reverse.join(' ') }
      .flatten

    # транслит
    #phrases = (phrases + phrases.map {|v| Russian::translit v }).uniq

    # [ТВ-1]
    phrases = multiply_phrases phrases, /\[?(тв|ova)\s*-?\s*\d\]?$/, ''
    phrases = multiply_phrases phrases, / \[?tv\]?$/, ''
    # (2000)
    phrases = multiply_phrases phrases, /[\[\(]\d{4}[\]\)]$/, ''

    phrases = multiply_phrases phrases, / season (\d+)/, ' s\1'
    phrases = multiply_phrases phrases, / s(\d+)/, ' season \1'
    phrases = multiply_phrases phrases, / 2nd season$/, ' s2'

    phrases = multiply_phrases phrases, /^the /, ''
    phrases = multiply_phrases phrases, /magika/, 'magica'
    phrases = multiply_phrases phrases, /(?<= )2$/, '2nd season'
    phrases = multiply_phrases phrases, /(?<= )3$/, '3rd season'
    phrases = multiply_phrases phrases, / plus$/, '+'
    phrases = multiply_phrases phrases, / the animation$/, ''
    phrases = multiply_phrases phrases, / series \d$/, ''
    phrases = multiply_phrases phrases, /\bspecial\b/, 'specials'

    phrases = multiply_phrases phrases, '!', ''

    # разлинчные варианты написания одних и тех же слов и фраз
    phrases = multiply_phrases phrases, ' and ', ' & '
    phrases = multiply_phrases phrases, ' & ', ' and '
    phrases = multiply_phrases phrases, ' o ', ' wo '
    phrases = multiply_phrases phrases, ' wo ', ' o '
    phrases = multiply_phrases phrases, 'u', 'h'

    phrases = multiply_phrases phrases, /(?<!u)u(?!u)/, 'uu'
    phrases = multiply_phrases phrases, /s(?!h)/, 'sh'
    phrases = multiply_phrases phrases, /(?<=[wrtpsdfghjklzxcvbnm])o/, 'ou'

    phrases = multiply_phrases phrases, /(?<= )([456789])$/, '\1th season'
    phrases = multiply_phrases phrases, "(#{kind.downcase})", '' if kind && name.include?("(#{kind.downcase})")

    phrases.map {|name| fix name }.uniq
  end

  def multiply_phrases phrases, from, to
    (phrases + phrases.map {|v| v.sub(from, to).strip }).uniq
  end

  # все возможные варианты написания имён
  def variants names
    [names]
      .flatten
      .map(&:downcase)
      .map {|name| phrase_variants name }
      .flatten
      .uniq
      .select(&:present?)
  end

  # разбитие фразы по запятым, двоеточиям и тире
  def split_by_delimiters name, kind=nil
    names = (name =~ /:|-/ ?
      name.split(/:|-/).select {|s| s.size > 7 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      []) +
    (name =~ /,/ ?
      name.split(/,/).select {|s| s.size > 10 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      [])

    names
      .flatten
      .select {|v| fix(v) !~ /\A(\d+|сезонпервый|сезонвторой|сезонтретий|спецвыпуск\d+|firstseason|secondseason|thirdseason|anime|theanime)\Z/ }
      .select {|v| fix(v).size > 3 }
  end

  # заполнение кеша
  def build_cache
    datasource.each do |entry|
      names = {
        name: main_names(entry),
        alt: alt_names(entry),
        russian: russian_names(entry)
      }
      names.each {|k,v| v.map!(&:downcase) }
      names[:alt2] = alt2_names(entry, names[:alt])

      names.each {|k,v| names[k] = (v + v.map {|name| fix name }).uniq }

      names.each do |group,names|
        names.each do |name|
          @cache[group][name] ||= []
          @cache[group][name] << entry
        end
      end

      # идентификаторы привязанных сервисов
      entry
        .links
        .select {|v| @services.include?(v.service.to_sym) }
        .each {|link| @cache[link.service.to_sym][link.identifier] = entry } if @services.present?
    end
  end

  def main_names entry
    names = [entry.name, "#{entry.name} #{entry.kind}"]
    synonyms = entry.synonyms.map {|v| "#{v} #{entry.kind}" } + (entry.aired_at ? entry.synonyms.map {|v| "#{v} #{entry.aired_at.year}" } : []) if entry.synonyms
    english = entry.english.map {|v| "#{v} #{entry.kind}" }  + (entry.aired_at ? entry.english.map {|v| "#{v} #{entry.aired_at.year}" } : []) if entry.english
    aired_at = ["#{entry.name} #{entry.aired_at.year}"] if entry.aired_at

    names + (synonyms || []) + (english || []) + (aired_at || [])
  end

  def alt_names entry
    [entry.name] + (entry.synonyms ? entry.synonyms : []) + (entry.english ? entry.english : [])
  end

  def alt2_names entry, alt1_names
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

    ds.select(FIELDS)
      .all
      .sort_by {|v| v.kind == 'TV' ? 0 : 1 } # выборку сортируем, чтобы TV было последним и перезатировало всё остальное
  end

  def predefined_matches
    config = YAML::load(File.open("#{::Rails.root.to_s}/config/alternative_names.yml"))[@klass.table_name]
    entries_by_id = @klass
      .where(id: config.values)
      .select(FIELDS)
      .each_with_object({}) {|v,memo| memo[v.id] = v }

    config.each_with_object({}) do |(k,v),memo|
      memo[fix k] = [entries_by_id[v]]
    end
  end
end
