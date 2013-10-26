# матчер названий аниме и манги со сторонних сервисов с названиями на сайте
class NameMatcher
  # конструктор
  def initialize(klass, ids=nil)
    # в каком порядке будем обходить кеш
    @match_order = [:name, :alt, :alt2]

    @klass = klass

    # хеш с названиями, по которому будем искать
    @cache = {
      name: {},
      alt: {},
      alt2: {}
    }

    ds = @klass.select([:name, :id, :english, :synonyms, :kind, :aired_at])
    ds = ds.where(id: ids) unless ids.nil?
    # выборку сортируем, чтобы TV было последним и перезатировало всё остальное
    ds.all.sort_by {|v| v.kind == 'TV' ? 1 : 0 }.each do |entry|
      all_names = {
        name:
          ["#{entry.name} #{entry.kind}"] +
          (entry.synonyms ?
            entry.synonyms.map {|v| "#{v} #{entry.kind}" } + (
              entry.aired_at ? entry.synonyms.map {|v| "#{v} #{entry.aired_at.year}" } : []
            ) :
            []
          ) +
          (entry.english ?
            entry.english.map {|v| "#{v} #{entry.kind}" }  + (
              entry.aired_at ? entry.english.map {|v| "#{v} #{entry.aired_at.year}" } : []
              ):
            []
          ) +
          (entry.aired_at ? ["#{entry.name} #{entry.aired_at.year}"] : []),
        alt:
          [entry.name] +
          (entry.synonyms ? entry.synonyms : []) +
          (entry.english ? entry.english : [])
      }
      all_names.each {|k,v| v.map!(&:downcase) }

      # отдельно будем пытаться матчить то, что содержит запятые, двоеточия и тире
      all_names[:alt2] = all_names[:alt].map do |name|
        get_variants(name, entry.kind)
      end.compact.flatten
      all_names[:alt2] = (all_names[:alt2] + all_names[:alt2].map {|v| v.gsub('!', '') }).uniq

      all_names.each do |k,v|
        all_names[k] = (v + v.map {|n| fix_name(n) }).uniq
      end

      all_names.each do |group,names|
        names.each do |name|
          @cache[group][name] = entry.id
        end
      end
    end
  end

  # поиск id аниме/манги по переданному наванию
  def get_id(name)
    fixed_name = fix_name(name)
    variants = ([name.downcase, fixed_name, fixed_name.gsub('!', '')] +
        get_variants(name.downcase) +
        get_variants(fix_name(name))
      ).flatten.uniq

    #ap variants
    #ap @cache
    variants.each do |variant|
      @match_order.each do |group|
        id = @cache[group][variant]
        return id if id
      end
    end

    #Rails.logger.info "#{name} #{fix_name(name)}\n"
    nil
  end

  def fetch_id(name)
    results = AniMangaQuery.new(Anime, search: name).fetch
    if results.count == 1
      results.first.id
    elsif results.any?
      puts "ambiguous result: \"#{results.map(&:name).join("\", \"")}\""
      nil
    else
      nil
    end
  end

private
  # фикс имени - вырезание из него всего, что можно
  def fix_name(name)
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
  def get_variants(name, kind=nil)
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

  # разбитие фразы по запятым, двоеточиям и тире
  def split_by_delimiters(name, kind=nil)
    (name =~ /:|-/ ?
      name.split(/:|-/).select {|s| s.size > 7 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      []) +
    (name =~ /,/ ?
      name.split(/,/).select {|s| s.size > 10 }.map(&:strip).map {|s| kind ? [s, "#{s} #{kind.downcase}"] : [s] } :
      [])
  end
end
