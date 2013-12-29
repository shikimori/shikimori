class WikipediaParser < SiteParserWithCache
  alias :super_load_cache :load_cache

  AnimeUrl = "http://ru.wikipedia.org/w/index.php?action=edit&title=%s"

  attr_accessor :proxy_log

  # конструктор
  def initialize
    super
    @required_text = 'MediaWiki'
    #@proxy_log = true
    @no_proxy = true
  end

  # загрузка кеша
  def load_cache
    super_load_cache

    if @cache[:animes] == nil
      @cache[:animes] = {}
      save_cache
    end
    if @cache[:characters] == nil
      @cache[:characters] = {}
      save_cache
    end
    print "cache loaded\n" unless Rails.env.test?
    @cache
  end

  # получение контента страницы с кеша или с сайта
  def fetch_anime(anime)
    print "fetching #{anime.class.name.downcase} ##{anime.id} \"#{anime.name}\"...\n" unless Rails.env.test?
    name = anime.name.gsub(/†/, ' ').gsub(/☆/, ' ').gsub(/★/, ' ')
    pages = [name] +
      (anime.russian.blank? ? [] : [anime.russian]) +
      (anime.english ? anime.english : []) +
      (anime.synonyms ? anime.synonyms : [])

    pages << name.sub(/^(.*?): (.*)$/, '\1 (\2)') if name =~ /.*: .*/
    pages << name.sub(/^(.*?): (.*)$/, '\1') if name =~ /.*: .*/

    pages.map! {|v| v.gsub(/ /, '_').gsub(/__+/, '_') }.uniq!

    print "found pages:\n#{pages.join("\n")}\n" unless Rails.env.test?
    fetch_pages(pages)
  end

  # получение контента страниц с википедии
  def fetch_pages(names)
    data = nil
    url = nil

    names.each do |name|
      url = AnimeUrl % name
      content = get(url, @required_text)
      next unless content
      next if content.include?('В Википедии нет статьи с таким названием') ||
              content.include?("В Википедии <b>нет статьи</b> с таким названием")

      if content
        data = content.gsub(/[\s\S]*?<textarea.*?>/, '').gsub(/<\/textarea>[\s\S]*/, '')
        next if content =~ /<textarea[\s\S]*?\{\{неоднозначность\}\}[\s\S]*?<\/textarea/
        next if content =~ /Breytingarágrip/
        break unless data.blank?
      end
    end

    return [] if data.blank?

    if data =~ /#(?:перенаправление|ПЕРЕНАПРАВЛЕНИЕ|redirect|redirecting) \[\[(.*?)\]\]\n/i
      content = get(AnimeUrl % $1, @required_text) || get(AnimeUrl % $1, @required_text)
      if content
        data = content.gsub(/[\s\S]*?<textarea.*?>/, '').gsub(/<\/textarea>[\s\S]*/, '')
      else
        return []
      end
    end

    if data =~ /^.*может значить:\n/ || data =~ /^'''.*?''':\n/ || data =~ /\{\{неоднозначность\}\}/
      return [[url, data]] + fetch_pages(
          data.gsub(/\n\* .*? \[\[ ( .*? ) (?:\| .*?)? \]\]/x).map { $1 }.select {|v| v =~ /аним|манг|anime|mang|игра/i }.map {|v| v.gsub(/ /, '_') }
        )
    end

    if data =~ /\{\{(?:main|Смотри также|see also):?\|((?:Список (отрицательных )?персонажей|Основные персонажи|Персонажи) .*?)\}\}/
      [[url, data]] + fetch_pages([$1.gsub(/ /, '_')])
    else
      [[url, data]]
    end
  end

  # получение списка персонажей аниме
  def extract_characters(anime, data=nil)
    is_first = data.nil?

    data = fetch_anime(anime) unless data
    return [] unless data

    data.map do |url,content|
      #chars = []
      chars = extract_default(content)
      chars += extract_default_old(content, is_first ? CharacterRegexp : CharacterDetailedRegexp).map {|v| v.merge source: url.sub('action=edit&', '') }

      extract_by_header(content).each do |h_char|
        is_exist = false
        chars.each do |char|
          if char[:russian] == h_char[:russian]
            is_exist = true
            char[:description] = h_char[:description] if h_char[:description]
            char[:english] = h_char[:english] if h_char[:english]
            char[:japanese] = h_char[:japanese] if h_char[:japanese]
            char[:source] = url.sub('action=edit&', '')
          end
        end
        chars << h_char.merge(source: url.sub('action=edit&', '')) unless is_exist
      end unless is_first

      is_first = false
      chars
    end.flatten
  end

  # выборка персонажей из оформления википедии заголовками
  def extract_by_header(content)
    content = cleanup_wikitext(content) + "EEENNNDDD"
    characters = []

    regex = /
      ===?=? # условие начала описания персонажа
        \s* (?:'''? \s* )? (?:\[\[? \s* )?
          (.*?)
        (?:\s* \]\]?)? (?:\s* '''?)? \s*
      ===?=?\n

      ( [\s\S]*? ) # описание персонажа

      (?= # условие окончания описания персонажа
        ===?
        |
        EEENNNDDD
      )
    /xi

    content.gsub(regex) do |v|
      char = {
        russian: cleanup_name($1)
      }

      next if char[:russian] == 'Персонажи'
      text = $2.strip

      #next if text.blank? || char[:russian].blank?

      header = nil
      if text =~ /
          ^ # должно быть с самого начала
          ( (?: (?: \n | ^ ) (?: \* | : ) \s* .*: .* \n )+ )? # необязательный список с ключевыми параметрами персонажа
          \{\{
            (?: nihongo | [Нн]ихонго ) .*? \|

            \s* (?:'''? \s* )? (?:\[\[? \s* )?
            ( .*? )  # имя
            (?:\s* \]\]?)? (?:\s* '''?)? \s*

            \| ( (?: [^{}]*? (?:\{\{ [^{}]*? \}\} [^{}]*?)? )+ ) # аттрибуты имени
          \}\}
        /xi

        h_name = $2.strip
        header = $3

        next if h_name != char[:russian] # если текст в блоке не совпадает с именем, то это не описание персонажа
      else
        # исключением будет спец блок с характеристиками персонажа. если он есть, значит это почти наверняка персонаж
        #unless text.starts_with? '**'
          #next # если в начале нет блока с именем, то это не описание персонажа
        #end
      end

#debugger if char[:russian] == 'Инуяся'
      char[:description] = cleanup_description(text, char)

      begin
        r = Regexp.new("^(?:\\[\\[)?#{char[:russian]}(?:\\]\\])?\n(?:\s|\n)*")
        char[:description].sub!(r, '')
      rescue
      end
      char[:description].sub!(/\s* ,? \s* \( .*? \) \s* \n /x, '')
      begin
        char[:description].sub!(Regexp.new("^(#{char[:russian].gsub(' ', ' \\s+ ')}) \\s* \\( .*? \\)", Regexp::EXTENDED), '\1')
      rescue
      end


      fill_character_english(char, header)
      fill_character_japanese(char, header)

      characters << char
    end

    characters
  end

  # выборка персонажей из дефолтного оформления википедии
  def extract_default(content)
    # замена блока {{Описание персонажа}}
    content.scan(/
        ^\{\{
          Описание \s персонажа
          \n
          (
            [\s\S]*?
          )
        ^\}\}$
    /x).map do |matches|
      traits = matches[0].split("\n").each_with_object({}) do |line, memo|
        splits = line.sub(/^\s*\|\s*/, '').split('=').map(&:strip)
        memo[splits.first] = splits.last
      end

      {
        russian: cleanup_name(traits['имя']),
        japanese: traits['кандзи'],
        description: traits['описание']
      }
    end
  end

  # выборка персонажей из старого дефолтного оформления википедии
  def extract_default_old(content, regexp)
    content = cleanup_wikitext(content)
    content = if content =~ /== (Персонажи|Главные герои) ==/
      content
        .sub(/[\s\S]*?== (Персонажи|Главные герои) ==/, '')
        .gsub(/===? (Прочие персонажи|Злодеи|Совет Злодеев) ===?/, '')
        .gsub(/\n== [\s\S]*/, '') + "EEENNNDDD"
    else
      content + "EEENNNDDD"
    end
    characters = []

    content.gsub(regexp) do |v|
      header = ($2 || $4 || $6 || $8)
      char = {
        russian: cleanup_name($1 || $3 || $5 || $7)
      }

      char[:description] = cleanup_description(regexp == CharacterDetailedRegexp ? $9 : $5, char)

      # перенос куска в header из description
      if char[:description] =~ /^ (\s* \( \{\{ .*? \}\} .*? \) \s*)+ ([\s\S]*) /x
        if header
          header += $1
        else
          header = $1
        end
        char[:description] = $2
      end

      fill_character_english(char, header)
      fill_character_japanese(char, header)

      next if char[:description].blank?
      next if char[:russian] == 'Сэйю'

      characters << char
    end
    characters.compact
  end

  # фильтр мусора из имени
  def cleanup_name(name)
    if name.blank?
      name
    else
      fixed = name
        .strip
        .gsub(/\[|\]/, '')
        .gsub('(персонаж)', '')
        .gsub(/^[= ]+|[= ]+$/, '')
        .sub(/.*\(полное имя (.*)\)/, '\1').sub(/\[\[.*\|(.*)\]\]/, '\1')
        .split('|')
        .last
     fixed.blank? ? '' : fixed.strip
    end
  end

  # вытаскивание английского имени из заголовка
  def fill_character_english(char, header)
    char[:english] = $1.strip if header =~ /\{\{lang-en\|(.*?)\}\}/
    if header =~ /''(.*?)''/ && char[:english].blank?
      english = cleanup_name($1)
      char[:english] = english if english =~ /[A-z\-,.'" ]+/
    end
    if char[:english].blank? && !header.blank?
      english = header.split('|').select {|v| v =~ /^[A-Za-z ]+$/ && !v.contains_cjkv? }.first
      char[:english] = cleanup_name(english) unless english.blank?
    end
  end

  # вытаскивание японского имени из заголовка
  def fill_character_japanese(char, header)
    char[:japanese] = cleanup_name($1) if header =~ /\{\{lang-ja\|(.*?)\}\}/
    char[:japanese] = cleanup_name($1) if char[:japanese].blank? && header =~ /^[{]*\|(.+?)(?:$|\|)/
    if char[:japanese].blank? && !header.blank?
      japanese = header.split('|').select(&:contains_cjkv?)
      char[:japanese] = cleanup_name(japanese.first) if japanese.any?
    end
  end

  # очистка текста из вики от мусора
  def cleanup_wikitext(text)
    data = text
        .gsub(/ /, ' ')
        .gsub(/—/, '-')
        .gsub(/\{\{cite\s*web\s*\| (.*?)\}\}/ix, '')
        .gsub(/\n:\s\{\{anime voices?.*?\}\}.*?(?=\n|$)/i, '')
        .gsub(/(&lt;|<)!-- [\s\S]*? !?-->\n?/x, '')
        .gsub(/(?:<|&lt;)ref([^\/>]+\/>|[\s\S]*?(?:<|&lt;)\/ref>)/, '')
        .gsub(/ (?: \* | \[\*\] | (\n)[ ]*\*?[ ]*''' ?) [ ]* \[?\[? С[еэ]йю \]?\]? (?:'''?)? : \s* (?:'''?)? .* \n /x, '\1') # \1 т.к. надо начальный \n сохранить
        .gsub(/(?:\: )?((?<!\|)\[\[|(?<!\[))С[еэ]йю\]?\]?(?: -| —|:) \{?\{?[^.]+?\}?\}?(?:\.|\n|;.*?\n|;)/, '')
        .gsub(/ \[\[ (?:[Фф]айл|File): [^\[\]\n]*? (?: \[\[ .*? \]\] [^\[\]\n]*? )* \]\] /ix, '')
        .gsub(/ \{\{ (?: (?:И|и)сточник | Source ) : .*? \}\}/xi, '')
        .gsub(/&lt;(\/?center>)/i, '<\1')
        .gsub(/&lt;(\/?blockquote>)/i, '')
        .gsub(/\[\[wiktionary:(.*?)\|.*?\]\]/i, '\1')
        .gsub(/\{\{[Нн]ет\b.*?\}\}/i, '')
        .gsub(/\{\{ref\b.*?\}\}/i, '')
        .gsub(/\{\{nl \| (?: [^}]+\| )* (.*?) \}\}/xi, '\1')
        .gsub(/\{\{tracklist[\s\S]*?\}\}/xi, '')
        .gsub(/\{\{нп3 .*? \| ([^|]*?) \}\}/xi, '\1')
        .gsub(/\{\{(anchor|[Яя]корь).*?\}\}/i, '')
        .gsub(/\{\{('''?)?(?:anime(?: |_|-)voices?|animage|примечания|уточнить|clear|anime-stub|section-stub|flagicon|основная статья|edgedale|термин|Переход\|).*?('''?)?\}\}/i, '')
        .gsub(/\{\{nobr\|(.*?)\}\}/i, '\1')
        .gsub(/\{\{(?:abbr|[Кк]итайский)\|([^|}]*?)(\|(.*?))?\}\}/i, '\1')
        .gsub(/\{\{vgy\|(?:(?:.*?\|)?(.*?))\}\}/i, '\1')
        .gsub(/\{\{(кто\??|who\??|чего|что|disambig)\}\}/i, '')
        .gsub(/\{\{-\}\}/, '')
        .gsub(/\{\{ [Хх]ангыль \| ([^|}\n]*?) \| ([^}\n]*? (?:\{\{ [^}\n]*? \}\})?)+ \}\}/x, '\1')
        .gsub(/\{\{ цитата\| (.*?) \}\}/x, '[quote]\1[/quote]')
        .gsub(/\{\{[Нн]е переведено.*?надо=([^\n|]+).*?\}\}/i, '\1')
        .gsub(/\{\{[Сс]мотри также.*?\}\}/i, '')
        .gsub(/(&lt;|<)gallery[^>]*?>[\s\S]*?(&lt;|<)\/gallery>/i, '')
        .gsub(/\{\{[Нн]ачало цитаты.*?\}\}[\s\S]*?\{\{[Кк]онец цитаты.*?\}\}/i, '')
        .gsub(/\{\{(?:что\?|what\?)\}\}/i, '')
        .gsub('&amp;nbsp;', ' ')
        .gsub('&nbsp;', ' ')
        .gsub('&amp;ndash;', ' ')
        .gsub('&ndash;', ' ')

    # замена блока {{Персонаж аниме/манги}}
    data.gsub!(/
        \{\{
          (?:Персонаж \s аниме\/манги|Кратко \s о \s [А-яA-z0-9 ]+?|Персонаж \s [А-яA-z0-9 ]+?) \|?
          \n
          (
            (?: [^{}]*? (?: \{\{ .*? \}\} )? )+
          )
        \}\}
      /x) do

      block = $1.gsub(/\n\s*\*.*/, '') # чистка блоков с мусором
      block.gsub(/\s* \| \s* ([^=\n]+?) \s* = \s* ([^=\n]*?) \s* \n /x) do
        key = $1
        value = $2.sub(/^(?:<|&lt;)br ?\/?>/, '')

        key = key.gsub(/^[А-яA-z0-9]/) {|v| Unicode.upcase(v) }

        key = 'Появление' if key == 'Первое'

        value = value.gsub(/\s*,?\s*(?:<|&lt;)br ?\/?>\s*/, ', ')

        if key =~ /^(Цвет|Имя|С[еэ]йю|Акт[её]р|Умер(ла)?|Родил(ся|ась)|Киридзи|Ромадзи|Пол|Прозвище|Изображение|bgcolor|fgcolor)$/i ||
            value.blank?
          nil
        else
          "** #{key}: #{value}\n"
        end
      end
    end

    data.gsub(/(?:&lt;|<)br ?(?:clear="?(?:left|right|both|all)"?)? ?\/?>/, "\n")
  end

  # очистка персонажа от мусора
  def cleanup_description(text, char)
    text.strip!

    # очистка от блока {{main}}
    text.gsub!(/\{\{main.*?\}\}/, '')

    #ap text
    #ap 'c'
    # очистка от имён
    text.gsub!(/
      \{\{
        (?: nihongo | [Нн]ихонго ) .*? \|
        (?: ''' | '' )? ( .*? ) (?: ''' | '' )? \|
        (?: [^{}]*? (?:\{\{ [^{}]*? \}\} [^{}]*?)? )+
      \}\}
    /xi, '\1')

    # замена списков в начале описания
    #\n: test\n: test -> [list][*] test\n[*] test[/list]
    if text =~ /^(\n? (?: :|\*\*? ) .*?) ( (?:\n (?: :|\*\*? ) .*?)+ ) /x || text =~ /^(\n? \*\* .*?) /x
      text.gsub!(/^( (?: (?:\n|^) (?: :|\*\*? ) .*? (?=\n|$) )+ ) /x, "[list]\n\\1\n[/list]")
      text.gsub!(/( (?:(\n|^) (?: :|\*\*? ) .*? (?=\n|$)) ) /x) do |v|
        name_regexp = /(\n|^)[:* ]+(Кандзи|Кана|Катакана|Англ): /
        if v =~ name_regexp
          # надо попытаться вытащить из списка японское и английское имя
          name_key = $1 == 'Англ' ? :english : :japanese

          if name_key == :english && char[name_key].blank?
            char[name_key] = v.sub(name_regexp, '')
          elsif name_key == :japanese
            char[name_key] = char[name_key].blank? ? v.sub(name_regexp, '') : char[name_key] + ',' + v.sub(name_regexp, '')
            char[name_key] = char[name_key].split(',').uniq {|v| v.gsub(/ |・|＝|,/, '') }.join(',')
          end
          v.gsub(/[\s\S]*/, '')
        else
#debugger if char[:russian] == 'Сома Огами'
          # а если не получилось, то делаем обычную замену на ббкоды списка
          v.gsub(/(\n|^)[:* ]+/, "\n[*] ")
        end
      end
      text.gsub!(/^\n/, '')
    else
      # очистка от : и * в начале
      text.gsub!(/^(::?|\*) ?/, '')
    end

    # очистка от имён в кавычках
    text.gsub!(/'''(.*?)'''/, '\1')
    text.gsub!(/''(.*?)''/, '\1')

    # исправление тире и запятой в начале описания
    if text =~ /^(—|-|,)/
      text.gsub!(/^(?:—|-|,) ?(\[?\[?[А-яA-z0-9])?/) {|v| $1 ? Unicode.upcase($1) : '' }
    end

    # удаление имени из начала
    begin
      name_start = Regexp.new("^\s*(?:;\s*)?" + char[:russian] + " ?(?:,|-|—|<br ?\\/?>|\\n) ?(\\[?\\[?\[А-яA-z0-9])?")
      text.gsub!(name_start) {|v| $1 ? Unicode.upcase($1) : '' }
    rescue
    end

    # удаление Сейю из начала
    text.sub!($1, '') if text =~ /^((?:(?:\*|:|\[\*\]) ?)?С[еэ]йю (?:—|:|-).*?\n)/
    # удаление Сейю из конца
    1.upto(2) do
      text.sub!($1, '') if text =~ /
        \n
        (
          (?: (?: \*|:|\[\*\] )? )?
          (?:'''|'')?
          (?:\[\[)?
            (?:С[еэ]йю|Акт[ёе]р)
          (?:\[\[)?
          (?:'''|'')?
          \s*
          (?:—|:|-|в )
          .*?
          \n?$
        )
      /x
    end

    # чистка тегов {{lang
    text.gsub! /\{\{ lang-.*? \| (.*?) \}\}/xi, '\1'

    # чистка блока wikitable до самого конца!!!
    text.gsub! /\|-[\s\S]*/, ''

    # первая буква должна быть большой
    text.gsub!(/^ ?([а-яa-z])/) {|v| Unicode.upcase($1) } if text =~ /^ ?[а-яa-z]/

    # тег center
    text.gsub!(/<center>([\s\S]*?)<\/center>/, '[b]\1[/b]')

    # финальная чистка мусора
    text.strip!
    # удаление точки из начала
    text.sub!(/^\s*\.\n?\s*/, '')
    # добавление точки в конец
    #text.sub!(/\.?$/, '.') unless text.blank?
    text.strip!

    text
  end

  CharacterRegexp = /
    (?:
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* \{\{
                                                        (?: nihongo | [Нн]ихонго ) .*? \|?
                                                        (?: '''? | \| ) # во что обрамлено имя персонажа
                                                          ( \[\[ [^\n}']*? \]\] | [^\n}']*? ) # имя персонажа
                                                        (?: '''? | \| ) # во что обрамлено имя персонажа
                                                        ( (?: [^{}]*? (?:\{\{ [^{}]*? \}\} [^{}]*?)? )+ )
                                                  \}\}
                                                  (?: (?:\s|\.|) \( .*? \) )?
      |
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* ''' ( .*? ) ''' (?:\s|\.) (?: \( (.*?) \) (?:[ ]* ; [ ]* .*)? )?
    )

    (?: \/ .*? \n )? # может быть блок с какой-то дополнительной информацией

    ( [\s\S]*? )

    (?= # условие окончания описания персонажа
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* \{\{ (?: nihongo | [Нн]ихонго )
      |
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* '''
      |
      ==
      |
      EEENNNDDD
    )/xi

  CharacterDetailedRegexp = /
    (?:
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* \{\{ # вариант имени в нихонго
                                                        (?: nihongo | [Нн]ихонго ) .*? (?= \| ) \|?
                                                        (?: '''? | \| ) # во что обрамлено имя персонажа
                                                          ( \[\[ [^\n}']*? \]\] | [^\n}']*? ) # имя персонажа
                                                        (?: '''? | \| ) # во что обрамлено имя персонажа
                                                        ( (?: [^{}]*? (?:\{\{ [^{}]*? \}\} [^{}]*?)? )+ )
                                                 \}\}
      |
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* ''' ( .*? ) ''' (?:\s|\.) (?: \( (.*?) \) (?:[ ]* ; [ ]* .*)? )?  # вариант имени в '''
      |
      \{\{ main \| ( .*? ) () \}\} # вариант имени в {{main }}
      |
      \n === \s* ( .*? ) \s*  === () (?= \n :? \s* ''') # вариант имени в === с началом списка сразу на след строке
    )

    (?: \/ .*? \n )? # может быть блок с какой-то дополнительной информацией

    (
      (?: \n (?:\*|:) \s* '''.*?''' .* )* # список с ключевыми параметрами персонажа
      [\s\S]*? # описание персонажа
    )

    (?= # условие окончания описания персонажа
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* \{\{ (?: nihongo | [Нн]ихонго )
      |
      \n (?: \* | : | ; | \*\* (?:\s \*)? )? \s* '''
      |
      ==
      |
      EEENNNDDD
    )/xi
end
