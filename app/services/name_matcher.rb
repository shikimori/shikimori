# матчер названий аниме и манги со сторонних сервисов с названиями на сайте
class NameMatcher
  # конструктор
  def initialize klass, ids=nil, services=[]
    # в каком порядке будем обходить кеш
    @match_order = [:name, :alt, :alt2]

    @klass = klass
    @ids = ids
    @services = services

    # хеш с названиями, по которому будем искать
    @cache = {
      name: {},
      alt: {},
      alt2: {}
    }
    services.each {|service| @cache[service] = {} }

    build_cache
  end

  # поиск id аниме по переданному наванию
  def get_id name
    variants([name]).each do |variant|
      @match_order.each do |group|
        ids = @cache[group][variant]
        return ids.first if ids
      end
    end

    nil
  end

  # поиск всех подходящих id аниме по переданным наваниям
  def get_ids names
    variants(names).map do |variant|
      @match_order.map {|group| @cache[group][variant] }
    end.flatten.compact
  end

  # выборка id аниме по однозначному совпадению по простым алгоритмам поиска AniMangaQuery
  def fetch_id name
    results = AniMangaQuery.new(@klass, search: name).fetch

    if results.count == 1
      results.first.id

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
    if name
      name.downcase
          .force_encoding('utf-8')
          .gsub(/[-:,.~)(]/, '')
          .gsub(/`/, '\'')
          .gsub(/([A-z])0(\d)/, '\1\2')
          .gsub(/ /, '')
          .gsub(/☆|†|♪/, '')
          .strip
    end
  end

  # получение различных вариантов написания фразы
  def phrase_variants name, kind=nil
    variants = split_by_delimiters(name, kind) +
      [name =~ / and / ? name.sub(' and ', ' & ') : nil,
       name =~ / & / ? name.sub(' & ', ' and ') : nil,
       name =~ / season (\d)/ ? name.sub(/ season (\d+)/, ' s\1') : nil,
       name =~ / s(\d)/ ? name.sub(/ s(\d+)/, ' season \1') : nil,
       name =~ /^the / ? name.sub(/^the /, '') : nil,
       name =~ /magika/ ? name.sub(/magika/, 'magica') : nil,
       name =~ /magica/ ? name.sub(/magica/, 'magika') : nil,
      ]

      # с альтернативным названием в скобках
      if name =~ /\(.{5}.*?\)/
        variants.concat name.split(/\(|\)/).map(&:strip)
      end

      variants.compact
  end

  # все возможные варианты написания имён
  def variants names
    [names].flatten.map do |name|
      fixed_name = fix name

      binding.pry if name.nil?
      [name.downcase, fixed_name, fixed_name.gsub('!', '')] +
          phrase_variants(name.downcase) +
          phrase_variants(fixed_name)
    end.flatten.uniq
  end

  # разбитие фразы по запятым, двоеточиям и тире
  def split_by_delimiters name, kind=nil
    (name =~ /:|-/ ?
      name.split(/:|-/).select {|s| s.size > 7 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      []) +
    (name =~ /,/ ?
      name.split(/,/).select {|s| s.size > 10 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      [])
  end

  # заполнение кеша
  def build_cache
    datasource.each do |entry|
      names = {
        name: main_names(entry),
        alt: alt_names(entry)
      }
      names.each {|k,v| v.map!(&:downcase) }

      # отдельно будем пытаться матчить то, что содержит запятые, двоеточия и тире
      names[:alt2] = names[:alt].map {|name| phrase_variants name, entry.kind }.compact.flatten
      names[:alt2] = (names[:alt2] + names[:alt2].map {|v| v.gsub('!', '') }).uniq

      names.each {|k,v| names[k] = (v + v.map {|name| fix name }).uniq }

      names.each do |group,names|
        names.each do |name|
          @cache[group][name] ||= []
          @cache[group][name] << entry.id
        end
      end

      # идентификаторы привязанных сервисов
      entry
        .links
        .select {|v| @services.include?(v.service.to_sym) }
        .each {|link| @cache[link.service.to_sym][link.identifier] = entry.id } if @services.present?
    end
  end

  def main_names entry
    names = ["#{entry.name} #{entry.kind}"]
    synonyms = entry.synonyms.map {|v| "#{v} #{entry.kind}" } + (entry.aired_at ? entry.synonyms.map {|v| "#{v} #{entry.aired_at.year}" } : []) if entry.synonyms
    english = entry.english.map {|v| "#{v} #{entry.kind}" }  + (entry.aired_at ? entry.english.map {|v| "#{v} #{entry.aired_at.year}" } : []) if entry.english
    aired_at = ["#{entry.name} #{entry.aired_at.year}"] if entry.aired_at

    names + (synonyms || []) + (english || []) + (aired_at || [])
  end

  def alt_names entry
    [entry.name] + (entry.synonyms ? entry.synonyms : []) + (entry.english ? entry.english : [])
  end

  def datasource
    ds = @klass
    ds = ds.where id: @ids if @ids.present?
    ds = ds.includes(:links) if @services.present?

    ds.select([:name, :id, :english, :synonyms, :kind, :aired_at])
      .all
      .sort_by {|v| v.kind == 'TV' ? 0 : 1 } # выборку сортируем, чтобы TV было последним и перезатировало всё остальное
  end
end
