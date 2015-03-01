# парсер ридманги
class ReadMangaParser < SiteParserWithCache
  include ReadMangaImportData

  PageSize = 100

  # конструктор
  def initialize
    super

    @catalog_url = "http://#{domain}/list?type=&sortType=DATE_UPDATE&max=#{self.class::PageSize}&offset=%d"
    @entry_url = "http://#{domain}/%s"

    @required_text = ["#{self.class.name.sub('Parser', '')}.ru", '</html>']

    @no_proxy = true
    #@proxy_log = true
  end

  # загрузка кеша
  def load_cache
    super

    unless @cache[:entries]
      @cache[:entries] = {}
      save_cache
    end

    print "cache loaded\n" if Rails.env != 'test'
    @cache
  end

  # число страниц в каталоге
  def fetch_pages_num
    content = get(@catalog_url % 0)
    doc = Nokogiri::HTML content
    last_page_link = doc.css('.pagination').first.css('a')[-2]
    last_page_link.text.to_i
  end

  # загрузка элементов со страницы
  def fetch_pages pages
    data = []
    pages.each do |page|
      fetch_entries(fetch_page_links(page)).compact.each do |entry|
        data << entry
        @cache[:entries][entry[:id]] = entry
      end
    end
    save_cache
    data
  end

  # ссылки с конкретной страницы
  def fetch_page_links page
    content = get(@catalog_url % [page * self.class::PageSize])
    doc = Nokogiri::HTML(content)

    doc.css('.tiles .tile .img a').map do |a_tag|
      a_tag.attr('href').sub(/^.*\//, '')
    end.select {|v| v !~ /\?/ }
  end

  # загрузка пачки элементов
  def fetch_entries ids
    ids.map { |id| fetch_entry(id) }
  end

  # парсинг информации о манге по идентификатору
  def fetch_entry id
    url = @entry_url % id
    content = get url
    return nil if moved_entry? content

    entry = { id: id }

    doc = Nokogiri::HTML(content.gsub(/<br ?\/?>/, "\n").gsub(/<!--[\s\S]*?-->/, ''))

    extract_names entry, doc
    entry[:score] = doc.css('.rate_info b').first.text.sub(',', '.').sub('/10', '').to_f

    lines = extract_description_lines doc
    entry[:source] = find_source(lines, url) || url
    entry[:read_first_url] = extract_read_first_url doc

    entry[:description] = build_description lines, entry[:id]
    return nil if moved_entry? entry[:description]

    extract_additional entry, doc

    entry
  end

  def extract_names entry, doc
    h1_tag = doc.css('h1').first()
    entry[:names] = [
        h1_tag.css('.name').text,
        h1_tag.css('.eng-name').text,
        h1_tag.css('.jp-name').text,
        h1_tag.css('.original-name').text,
      ]
    entry[:names] = entry[:names].compact.map(&:strip).select(&:present?).map {|v| v.sub(/ \[ТВ.*?\]$/, '') }
    entry[:russian] = entry[:names].first

    if entry[:names].first.include?(':')
      names = entry[:names].first.split(':').map(&:strip)

      entry[:names] += case names.size
        when 2 then (!entry[:russian] || (entry[:russian] && !entry[:russian].include?(':'))) ? names : []
        when 3 then ["#{names[0]}: #{names[1]}", "#{names[1]}: #{names[2]}"]
        when 4 then ["#{names[0]}: #{names[1]}", "#{names[2]}: #{names[3]}"]
        else names
      end
    end
  end

  def extract_read_first_url doc
    link = doc.css('.read-first').css('a').first
    "#{link.attr('href')}?mature=1" if link
  end

  def extract_additional entry, doc
    kind = doc.css('h1').first().children().first().text.strip
    entry[:kind] = extract_kind kind
  end

  # перевод русского типа манги в английский
  def extract_kind kind
    case kind
      when 'Манга' then 'Manga'
      when 'Сингл' then 'One Shot'
      else
        raise "unexpected russian kind: '#{kind}'"
    end
  end

  # поиск источника в сточках изи возврат дефолтного урла
  def find_source lines, url=nil
    lines.reverse_each do |line|
      next if line.size > 100
      source = extract_source(line, url)
      return source if source
    end
    nil
  end

  # попытка вытащить источник из строки
  def extract_source line, url=nil
    line = line.gsub(/\([cCсС]\)/, '©').gsub(/^\(|\)$/, '')
    if line =~ /
        ^
          (?: [Ии]сточник:? \s? )?
          (?: [Оо]писание \s взято \s с:? (?: \s сайта)? \s? (?: \s переводчиков)? :? \s? )?
          (?: [Бб]олее \s подробоно:? \s? )?
          (?: [Сс]айт \s переводчиков:? \s? )?
          (?: [Вв]зят[оь] \s с:? \s? )?
          (?:
            (?: [Оо]писание|[Ии]нформация? \s )
            (?: манги \s )?
            (?: взя?т[оа] \s )?
            (?: составлено|с \s )?
            (?: сайта \s )?
            :?
          )?
          (?: С \s? )?
          (?: Спасибо \s за \s описание \s сайту:? \s? )?

          ( (?:http:\/\/)? [\w -.]+ \. (?:ru|net|org|com|ua|su|info)\/? | http:\/\/ .* | www\. .* )
        $
      /ix
      $1.sub(/^http:\/\/|^/, 'http://').downcase.gsub(' ', '')
    elsif line =~ /^http:\/\/.*$/i || line =~ /^www\..*$/i
      line.sub(/^http:\/\/|^/, 'http://')
    elsif line =~ /^ (?:(?:copyright \s)? © | [Оо]писание \s (?:составлено|с):? | [Вв]зято \s (?:составлено|с):? ) \s* (.*) $ /ix || line =~ /^ (.*) \s* © $ /ix
      value = $1
      # пробуем сначала определить проект
      project = recognize_project(value)
      # если не получилось, то, возможно, там есть урл
      project = value.sub(/^http:\/\/|^/, 'http://') if !project && value =~ /^((?:http:\/\/)?[\w -.]+\.(?:ru|net|org|com|ua|su|info))$/i
      # а если и его нет, то через запятую может быть проект указан
      if value.include?(',') && project.blank?
        project = recognize_project(value.split(',')[1])
        project = "© #{value.split(',')[0].strip}, #{project}" if project
      end

      project ? project : "© #{value.strip}#{url ? ', '+url : ''}"
    elsif project = recognize_project(line)
      project
    elsif line =~ /^..\/..\/[^ ]+$/
      @entry_url % line.sub(/^..\/..\//, '')
    elsif person = recognize_translator(line)
      "© #{person}#{url ? ', '+url : ''}"
    else
      nil
    end
  end

  # преобразование названия проекта его урл
  def recognize_project name
    MangaTeams[name.downcase.gsub(/\.$|~$|^~|^\(|\)$/, '').strip]
  end

  # определение переводчика из строки
  def recognize_translator text
    cleaned = text.gsub(/^by |\^-\^$|^Только ваш,|^~/, '').strip
    Translators.include?(cleaned.downcase) ? cleaned : nil
  end

  # построние описания из строк
  def build_description lines, id
    return "" if NoDescription.include?(id)

    should_stop = false

    lines.select do |line|
      # после постскриптупа описание не берём
      should_stop = true if line == 'PS'

      !should_stop &&
        !(line =~ /Название:/ && line.size < 40) &&
        (
          (FullDescription.include?(id) && !extract_source(line)) ||
          line == lines.first ||
          content_line?(line, id)
        )
    end.join("\n").sub(/^Краткое описание:\s*/, '').sub(/^Описание:\s*/, '')
  end

  # вытаскивание строк с описанием из дом дерева
  def extract_description_lines doc
    nodes = doc.css('.manga-description').children()

    nodes.map do |node|
      text = node.text

      if !text.blank? && node.css('a').any? && (
           (node.children.size == 1 && node.css('a').text == node.text) ||
           text.starts_with?('Описание взято') ||
           text.starts_with?('Описаниe взято') ||
           text.starts_with?('Описание взто') ||
           text.starts_with?('Описание предоставлено')
          )
        href = node.css('a').first.attr('href') || ''

        !href.include?('readmanga.ru') && !href.include?('findanime.ru') && !href.include?('doramatv.ru') ? href : '' # ссылки на сайты ридманги не нужны
      else
        normalize_line(text)
      end || ''
    end.map { |line| line.split("\n") }.flatten
  end

  # нормализация строки
  def normalize_line text
    text.blank? ? '' : text.gsub(' ', ' ')
                           .gsub(/([A-zА-яё] ?)\r?\n([ёА-яA-z])/, '\1 \2')
                           .gsub(/([A-zА-я.ё] ?)\r?\n([ёа-яa-z])/, '\1 \2')
                           .gsub("\r\n", "\n")
                           .gsub(/ +/, ' ')
                           .gsub(/\n+/, "\n")
                           .strip
  end

  # содержит ли строка описание?
  def content_line?(line, id=nil)
    is_source = extract_source(line)

    is_content = !line.blank? &&
      !is_source && (
        line.size > 35 ||
        line.contains_russian? ||
        line =~ /^\s*\d+(?:-\d+)?(?:\.|\)| )/ || # перечисление
        line =~ /^Пейринг/ || # яой
        line =~ /^\s*Remix/ || # яой
        line =~ /^--/ || # яой
        line =~ /^ x / # яой
      ) &&
      line !~ /^Смотреть .* на сайте.*$/ &&
      line != 'Одноименная дорама здесь' &&
      line != 'Приятного чтения!' &&
      line !~ /^У этой манги есть (?:продолжение|сиквел)/ &&
      line !~ /^[Пп]редыстория манги/ &&
      line !~ /^[Пп]родолжение (?:этой манги|истории)/ &&
      line !~ /^[Сс]иквел к манге/ &&
      line !~ /^[Оо]сновная манга/ &&
      line !~ /^[Уу] этой манги есть приквел / &&
      line !~ /^Дорама(?: \d+|$)/ &&
      line !~ /^По этой манге снята дорама/ &&
      line !~ /^Аниме-сериал \d+/ &&
      line !~ /^Редактировать описание манги/ &&
      line !~ /^Live-action/ &&
      line !~ /^(?:С|Пр)иквел http/ &&
      line !~ /^(?:С|Пр)иквел манги/ &&
      line !~ /^Ссылка на приквел/ &&
      line !~ /на FindAnime.ru$/ &&
      line !~ /[Гг]лавы удалены по запросу/ &&
      line !~ /[Уу]далено по просьбе издательства/ &&
      !(line.size < 50 &&
        (line.include?('(Приквел)') ||
          line.include?('(Сиквел)')
        )
      )

    print "\"#{id}\": \"#{line}\"\n" unless is_content || line.blank? || line.include?('(Приквел)') || line.include?('(Сиквел)') || is_source || Rails.env == 'test'
    is_content
  end

  # перенесена ли манга на другой сайт?
  def moved_entry? content
    content =~ /(расположена|находится|можно прочитать|Читать эту мангу) на (сайте )?Adult ?Manga/i || content =~ /МАНГА РАСПОЛОЖЕНА НА (сайте )?Adult ?Manga/i
  end

  def domain
    "#{self.class.name.downcase.sub 'parser', ''}.ru"
  end
end
