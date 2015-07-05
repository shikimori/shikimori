# матчер названий аниме и манги со сторонних сервисов с названиями на сайте
class NameMatcher
  attr_reader :cache

  ANIME_FIELDS = [:id, :name, :russian, :english, :synonyms, :status, :kind, :aired_on, :episodes, :rating, :censored]
  MANGA_FIELDS = [:id, :name, :russian, :english, :synonyms, :status,:kind, :aired_on, :chapters, :rating, :censored]

  BAD_NAMES = /\A(\d+|первыйсезон|второйсезон|третийсезон|сезонпервый|сезонвторой|сезонтретий|спецвыпуск\d+|firstseason|secondseason|thirdseason|anime|theanime|themovie|movie)\Z/

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
    found = matching_groups(Array(names).map {|v| fix v }).first ||
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

  def matching_groups fixed_names
    found_matches = fixed_names.each_with_object({}) do |variant,memo|
      @match_order.each do |group|
        memo[group] ||= []
        memo[group] << @cache[group][variant] if @cache[group][variant]
      end
    end

    found_matches.select {|group, matches| matches.any? }
  end

  # получение различных вариантов написания фразы
  def phrase_variants name, kind=nil, with_split=true
    return [] if name.nil?

    phrases = [name]

    phrases.concat split_by_delimiters(name, kind) if with_split

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
    phrases = multiply_phrases phrases, /\[?(тв|ova|tb)\s*-?\s*\d\]?$/, ''
    phrases = multiply_phrases phrases, / \[?tv\]?$/, ''
    # (2000)
    phrases = multiply_phrases phrases, /[\[\(]\d{4}[\]\)]$/, ''

    phrases = multiply_phrases phrases, / season (\d+)/, ' s\1'
    phrases = multiply_phrases phrases, / s(\d+)/, ' season \1'
    phrases = multiply_phrases phrases, / 2nd season$/, ' s2'

    phrases = multiply_phrases phrases, /^the /, ''
    phrases = multiply_phrases phrases, /\b2\b/, 'II'
    phrases = multiply_phrases phrases, /\bi\b/, ''

    phrases = multiply_phrases phrases, /kanojo/, 'heroine'

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

    String::UNACCENTS.each do |word, matches|
      phrases = multiply_phrases phrases, matches, word.downcase
    end

    phrases = multiply_phrases phrases, 'ß', 'ss'
    phrases = multiply_phrases phrases, '×', 'x'

    phrases = multiply_phrases phrases, /(?<!u)u(?!u)/, 'uu'
    phrases = multiply_phrases phrases, /s(?!h)/, 'sh'
    phrases = multiply_phrases phrases, /(?<=[wrtpsdfghjklzxcvbnmy])o(?!u)/, 'ou'

    phrases = multiply_phrases phrases, /(?<= )([456789])$/, '\1th season'
    phrases = multiply_phrases phrases, "(#{kind})", '' if kind && name.include?("(#{kind.downcase})")

    phrases.map {|name| fix name }.uniq
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

  # множественная замена фразы на альтернативы
  def multiply_phrases phrases, from, to
    multiplies = []

    phrases.each do |phrase|
      next_phrase = phrase

      10.times do
        replaced = next_phrase.sub(from, to).strip

        if replaced != next_phrase
          multiplies << replaced
          next_phrase = replaced
        else
          break
        end
      end
    end

    multiplies.any? ? phrases + multiplies : phrases
  end


  # все возможные варианты написания имён
  def variants names, with_splits=true
    Array(names)
      .map(&:downcase)
      .map {|name| phrase_variants name, nil, with_splits }
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
      .select {|v| fix(v) !~ BAD_NAMES }
      .select {|v| fix(v).size > 3 }
  end

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
    @services.each {|service| cache[service] = {} }

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
    config = YAML::load(File.open("#{::Rails.root.to_s}/config/alternative_names.yml"))[@klass.table_name]
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
end
