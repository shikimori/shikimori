class WikipediaImporter
  include Sidekiq::Worker
  sidekiq_options(
    queue: :slow_parsers,
    dead: false
  )
  sidekiq_retry_in { 60 * 60 * 24 }

  def perform options={}
    @translited_cache = {}
    options = HashWithIndifferentAccess.new options

    #Proxy.use_cache = true
    #Proxy.show_log = true

    @parser = WikipediaParser.new
    prepare_bundles options[:anime_ids], options[:manga_ids]
    process_bundles

    #Proxy.use_cache = false
    #Proxy.show_log = false
  end

  # формирование пачек связанных аниме и манг
  def prepare_bundles(anime_ids, manga_ids)
    print "fetching animes and mangas...\n"

    ds = Anime
      .includes(:related)
      .select([:id, :name, :russian, :english, :synonyms])
      .order(id: :desc)
    ds = ds.where(id: anime_ids) if anime_ids
    animes = ds.all.inject({}) do |rez,v|
      rez[v.id] = v
      rez
    end

    print "fetched #{animes.size} animes\n"

    ds = Manga
      .includes(:related)
      .select([:id, :name, :russian, :english, :synonyms])
      .where.not(id: [1315])
      .order(id: :desc)
    ds = ds.where(id: manga_ids) if manga_ids
    mangas = ds.all.inject({}) do |rez,v|
      rez[v.id] = v
      rez
    end

    print "fetched #{mangas.size} mangas\n"

    @bundles = []

    print "preparing bundles...\n"
    [animes, mangas].each do |pack|
      while pack.any?
        @bundles << get_related(pack.first[1], animes, mangas)
      end
    end
  end

  # обработка пачек аниме и манги
  def process_bundles
    print "processing #{@bundles.size} bundles"
    @bundles.each do |bundle|
      import_chars(filter_chars(get_chars(bundle)), bundle)
    end
  end

  # импорт описаний персонажей
  def import_chars(wiki_chars, bundle)
    return if wiki_chars.empty?

    anime_ids = bundle.select {|v| v.class == Anime }.map(&:id)
    manga_ids = bundle.select {|v| v.class == Manga }.map(&:id)
    char_ids = PersonRole
      .where("anime_id in (?) or manga_id in (?)", anime_ids, manga_ids)
      .where.not(character_id: nil)
      .group(:id)
      .pluck(:character_id)
      .uniq
    char_item_ids = ChangedItemsQuery.new(Character).fetch_ids

    db_chars = Character
      .where(id: char_ids)
      .where.not(id: char_item_ids + [12119,11734,20294,15470])
      .order(:name)
      .all

    imported = 0

    ambiguous_names = [db_chars, wiki_chars].map do |names|
      names
        .map {|v| [ v[:japanese], v[:english] || nil ].uniq }
        .flatten
        .compact
        .map {|v| v.cleanup_japanese.gsub('  ', ' ').split(/ |・|＝|,|\//) }
        .flatten
        .map(&:strip)
        .inject({}) {|rez,v|
          if rez[v] == nil
            rez[v] = 1
          else
            rez[v] += 1
          end
          rez
        }
        .select {|k,v| v > 1 }
        .map {|k,v| v > 1 ? k : nil }
        .compact
    end

    db_chars.each do |db_char|
      apply_mal_fixes(db_char)

      wiki_chars.each do |wiki_char|

        #if db_char.name == 'Chrome Dokuro' && wiki_char[:russian] == 'Хромэ Докуро'
          #ap db_char
          #ap wiki_char
          #ap ambiguous_names
          #raise 'end'
        #end

        if names_matched?(db_char, ambiguous_names[0], wiki_char, ambiguous_names[1])
          raise "bad description for #{db_char[:id]}-#{db_char[:name]}: \n#{wiki_char[:description_ru]}" if wiki_char[:description_ru] =~ /\*\*|\{\{|\}\}/

          description = DbEntries::Description.from_text_source(
            wiki_char[:description_ru],
            wiki_char[:source]
          )
          db_char.description_ru = description.text

          db_char.russian = wiki_char[:russian].sub('Сяна', 'Шана')
          db_char.japanese = wiki_char[:japanese] if !db_char[:japanese] && wiki_char[:japanese]

          db_char.save
          imported += 1
          break
        end
      end
    end
    print "\"#{bundle.first.name}\" wiki_chars: #{wiki_chars.size} db_chars: #{db_chars.size} imported: #{imported}\n"
  end

  # проверка на совпадение имён
  def names_matched?(db_char, ambiguous_db_names, wiki_char, ambiguous_wiki_names)
    return false if !db_char[:russian].blank? && !wiki_char[:russian].blank? && db_char[:russian] != wiki_char[:russian]
    return false if (db_char[:name].size - wiki_char[:russian].size).abs >= db_char[:name].size/2

    start = Time.now
    print "matching names: `#{db_char.name}` `#{wiki_char[:russian]} ... "

    db_names = [
      Unicode.downcase(db_char[:name].gsub(/  /, ' ').gsub('é', 'e')),
      db_char[:name].gsub(/^([^ ]+) ([^ ]+)$/, '\2 \1'),
      translited_names(db_char[:russian]),
      english_names(db_char[:fullname], ambiguous_wiki_names),
      japanese_names(db_char[:japanese], ambiguous_wiki_names)
    ].flatten.uniq.compact.select {|v| v.length > 0 }.map {|v| Unicode.downcase(v) }.uniq

    if wiki_char[:russian] =~ /^«.*»/
      wiki_char[:russian1] = wiki_char[:russian].sub(/.*«/, '').sub(/».*/, '')
      wiki_char[:russian2] = wiki_char[:russian].sub(/«.*»/, '')
    end
    wiki_names = [
      (
        wiki_char[:russian1] ?
          ( translited_names(wiki_char[:russian1]) || [] ) + ( translited_names(wiki_char[:russian2]) || [] ) :
          translited_names(wiki_char[:russian])
      ),
      wiki_char[:english],
      japanese_names(wiki_char[:japanese], ambiguous_db_names)
    ].flatten.uniq.compact.select {|v| v.length > 0 }.map {|v| Unicode.downcase(v) }.uniq

    #if db_char.name == 'Chrome Dokuro' && wiki_char[:russian] == 'Хромэ Докуро'
      #ap db_char
      #ap wiki_char
      #ap db_names
      #ap wiki_names
      #raise 'end'
    #end

    #ap [db_char[:name], (db_names & wiki_names)] if (db_names & wiki_names).any?

    print "%.3f ms\n" % [(Time.now - start)*100]
    (db_names & wiki_names).any?
  end

  # список имён, в которые можно транслителировать русское имя
  def translited_names(original)
    return nil if original.blank?
    return @translited_cache[original] if @translited_cache[original]

    name = Russian.translit(original).downcase

    names = [original, name, name.gsub(/\(.*\)/, '').strip].uniq
    return @translited_cache[original] = names if original.size > 50

    # различные варианты транслитерации
    [
      [/^([^ ]+) ([^ ]+)$/i, '\2 \1'],
      [/ey/i, 'ei'], # Heynkel -> Heinkel
      [/dzh/i, 'j'], # Dzhelso -> Jelso
      [/zha/i, 'jea'], # Zhan -> Jean
      [/dz/i, 'j'],
      [/dz/i, 'z'], # Inudzuka -> Inuzuka
      [/si/i, 'shi'], # Zasiki -> Zashiki
      [/ts/i, 'tz'], # Blits -> Blitz
      [/s([rwtpsdfghjklzxcvbnm][aeoyui])/i, 'su\1'], # Kenske -> Kensuke
      [/ndz/i, 'nz'],
      [/v/i, 'w'], # Kumakava -> Kumakawa
      [/^h/i, 'ch'], # Hrome -> Chrome
      [/ch/i, 'sh'], # Luchi -> Lushi
      [/ch/i, 'c'], # Luchchi -> Lucci
      [/tyan/i, 'chan'], # Sadi-tyan -> Sadi-chan
      [/(\w)ey($| )/i, '\1ay\2'], # Mey -> May
      [/yo(\w)/i, 'u\1'], # Cyortis -> Curtis
      [/(\w)yu(\w)/i, '\1ue\2'], # Fyuri -> Fueri
      [/(\w)ay(\w)/i, '\1ey\2'], # Haymans -> Heymans
      [/l/i, 'r'], # Holo -> Horo
      [/r/i, 'l'], # Horo -> Holo
      [/ch(\w)/i, 'c\1'], # Dolchetto -> Dolcetto
      [/iya/i, 'ia'], # Mariya -> Maria
      [/k([rwtpsdfghjklzxcvbnm])/i, 'ck\1'],
      [/z([aeoiuy])/i, 's\1'],
      [/([aeoiuy])tt([aeoiuy]| |$)/i, '\1t\2'], # Vatto -> Vato
      [/li/i, 'ley'],
      [/ey/i, 'ie'], # Kreyg -> Krieg
      [/ks/i, 'x'], # Foksi -> Foxi
      [/(\w)k(\w)/i, '\1c\2'], # Marko -> Marco
      [/li/i, 'lee'],
      [/-/i, ''], # Pen-Pen -> PenPen
      [/([rwtpsdfghjklzxcvbnm])u([rwtpsdfghjklzxcvbnm])/i, '\1oo\2'], # Pum -> Poom
      [/([rwtpsdfghjklzxcvbnm])o([rwtpsdfghjklzxcvbnm]| |$)/i, '\1oh\2'], # Marko -> Markoh, Toru -> Tohru
      [/([rwtpsdfghjklzxcvbnm])o($| )/i, '\1ou'], # Moto -> Mutou
      [/([rwtpsdfghjklzxcvbnm])e([rwtpsdfghjklzxcvbnm])/i, '\1a\2'],
      [/(^| )k/i, '\1c'], # Kornel -> Cornel
      [/(^| )dz/i, '\1z'], # Dzasiki -> Zasiki
      [/k($| )/i, 'c\1'], # Elrik -> Elric
      [/i($| )/i, 'ee\1'], # Kumani -> Kumanee
      [/([aeoiuy])n($| )/i, '\1ng\2'], # Chan -> Chang
      [/i($| )/i, 'y\1'] # Fuery -> Fueri
    ].each do |regexp, replacement|
      names = names.map do |name|
        parts = name.split(' ')

        case parts.size
          when 2
            [
              name,
              "#{parts[0].gsub(regexp, replacement)} #{parts[1]}",
              "#{parts[0]} #{parts[1].gsub(regexp, replacement)}",
              "#{parts[0].gsub(regexp, replacement)} #{parts[1].gsub(regexp, replacement)}"
            ]

          when 3
            [
              name,
              "#{parts[0].gsub(regexp, replacement)} #{parts[1]} #{parts[2]}",
              "#{parts[0].gsub(regexp, replacement)} #{parts[1].gsub(regexp, replacement)} #{parts[2]}",
              "#{parts[0].gsub(regexp, replacement)} #{parts[1].gsub(regexp, replacement)} #{parts[2].gsub(regexp, replacement)}",
              "#{parts[0]} #{parts[1].gsub(regexp, replacement)} #{parts[2]}",
              "#{parts[0]} #{parts[1].gsub(regexp, replacement)} #{parts[2].gsub(regexp, replacement)}",
              "#{parts[0]} #{parts[1]} #{parts[2].gsub(regexp, replacement)}",
              "#{parts[0].gsub(regexp, replacement)} #{parts[1]} #{parts[2].gsub(regexp, replacement)}"
            ]

          else
            [name, name.gsub(regexp, replacement)]
        end
      end.flatten.uniq
    end

#ap names if original == 'Эльза Скарлетт'

    @translited_cache[original] = names
  end

  # список имён, которые могут получиться из японского имени
  def japanese_names(name, ambiguous_names)
    return nil if name.blank?

    name = name.cleanup_japanese.gsub(/  /, ' ')
    names = [
      name.gsub(/ /, ''),
      name.gsub(/ |＝/, ''),
      name.gsub(/ |＝|,/, ''),
      name.gsub(/＝|,/, ''),
      name.gsub(/ |＝|,|\//, ''),
      name.gsub(/ |＝|,|\/|・/, '')
    ]

    [' ', '・', '＝', ',', '/'].each do |splitter|
      names += name.split(splitter).
          map {|v| v.gsub(/ /, '') }.
          select { |v| !ambiguous_names.include?(v) }.
          compact
    end

    # на конце бывает ー
    names << name+'ー'

    # может быть что-то в скобочках
    if name =~ /\(.*\)/
      fixed_name = name.gsub(/\(.*\)/, '').gsub(' ', '')
      names << fixed_name unless ambiguous_names.include?(fixed_name)
    end

    # от перестановки слагаемых...
    names << name.gsub(/^([^ ]+) ([^ ]+)$/, '\2 \1') if name.include? ' '

    names
  end

  # список имён, которые могут получиться из полного английского имени
  def english_names(name, ambiguous_names)
    return nil if name.blank?

    names = [name]

    names += name.gsub(/.*?"(.*?)".*/, '\1').split(/,/).
        map(&:strip).
        map {|v| [v, v.gsub(' ', '-')] }.
        flatten.
        uniq.
        select { |v| !ambiguous_names.include?(v) }.
        compact

    names
  end

  # загрузка персонажей пачки из википедии
  def get_chars(bundle)
    bundle.map do |entry|
      #if entry.name == 'One Piece'
        #"Пираты_Соломенной_Шляпы"
        #@parser.extract_characters(entry, @parser.fetch_pages([
          #"Список_персонажей_«One_Piece»"
        #])) +
        #@parser.extract_characters(entry, @parser.fetch_pages([
          #"Список_пиратов_«One_Piece»"
        #]))
      #else
        @parser.extract_characters(entry)
      #end
    end.flatten
  end

  # фильтрация списка персонажей по уникальности имени
  def filter_chars(bundle_chars)
    chars = {}
    bundle_chars.each do |char|
      unless chars.include?(char[:russian])
        chars[char[:russian]] = char
      else
        entry = chars[char[:russian]]

        if char[:description_ru].length > entry[:description_ru].length
          entry[:description_ru] = char[:description_ru]
        end
        if !entry.include?(:japanese) && char.include?(:japanese)
          entry[:japanese] = char[:japanese]
        end
        if !entry.include?(:english) && char.include?(:english)
          entry[:english] = char[:english]
        end
      end
    end
    chars.values
  end

  # получение из списка аниме и манги связанных с entry
  def get_related(entry, animes, mangas)
    (entry.class == Anime ? animes : mangas).delete(entry.id)

    bundle = [entry]

    entry.related.each do |related|
      rel = animes[related.anime_id] || mangas[related.manga_id]
      bundle += get_related(rel, animes, mangas) if rel
    end
    bundle
  end

  # список параметров элементов, заданных руками
  def mal_fixes
    unless @mal_fixes
      all_mal_fixes = YAML::load(File.open("#{::Rails.root.to_s}/config/app/mal_fixes.yml"))
      @mal_fixes = all_mal_fixes[:character]
    end
    @mal_fixes
  end

  def apply_mal_fixes(entry)
    mal_fixes[entry.id].each do |k2,v2|
      entry[k2] = v2
    end if mal_fixes.include?(entry.id)
  end
end
