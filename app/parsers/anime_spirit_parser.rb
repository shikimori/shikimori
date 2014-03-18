class AnimeSpiritParser
  def initialize
    @no_proxy = true
    @proxy_log = false
    @required_text = 'Animespirit'
  end

  # число страниц в каталоге
  def fetch_pages_num
    content = get catalog_url(1)
    doc = Nokogiri::HTML content
    last_page_link = doc.css('.navigation a')[-2]
    last_page_link.text.to_i
  end

  # загрузка элементов со страницы
  def fetch_pages pages
    pages.map {|page| fetch_page_links(page).map {|link| fetch_entry link } }.flatten
  end

  # загрузка ссылок со страницы каталога
  def fetch_page_links page
    content = get catalog_url(page)
    doc = Nokogiri::HTML content

    doc.css('.content-block .content-block-title a').map {|v| v.attr :href }
  end

  # парсинг информации об аниме по ссылке
  def fetch_entry link
    content = get link
    doc = Nokogiri::HTML content
    block = doc.css('.content-block')

    names = block.css('h2 a').first.text.split('/').map(&:strip)
    postprocess(
      id: link,
      russian: names.first,
      name: names.second,
      names: names,
      year: extract_year(content),
      videos: extract_videos(link, doc.css('.accordion')),
      categories: extract_categories(content),
      episodes: extract_episodes_num(content),
      author: extract_global_author(content)
    )
  end

  # выборка видео из nokogiri контента
  def extract_videos link, doc
    doc.css('h3,p').each_slice(3).map do |(name_tag,trash_tag,video_tag)|
      text = name_tag.text.strip

      next if text =~ /^[\[( -]*спешл|pv|трейлер/i
      next if text =~ /временно отсутствует/
      unless text =~ /(?<meta>)(?<episode>\d+)$/ ||
          text =~ /^(?:эпизод )?(?<episode>\d*).*\((?<meta>.+)\)(?: ?(?:\[|-|).+(?:\[|-|))?$/i ||
          text =~ /^(?:эпизод )?(?<episode>\d*).*(?<meta>) (?:\[|-).+(?:\[|-)$/i ||
          text =~ /^(?:эпизод )?(?<episode>\d*).*(?<meta>)$/i
        raise "can't parse entry: #{text} [#{link}]"
      end
      meta = $~[:meta].strip
      episode = ($~[:episode] || 0).to_i
      kind = extract_kind meta.present? ? meta : text
      #binding.pry if VideoExtractor::UrlExtractor.new(video_tag.text).extract == "http://myvi.ru/player/flash/oTeXdFuMc_QiH2OnQgziqKVw3m8VsxX-N5zbzTd50s5DufjzYAKc2iI3QDO89xNhn0"
      #binding.pry if VideoExtractor::UrlExtractor.new(video_tag.text).extract.blank?

      ParsedVideo.new(
        author: extract_author(meta, name_tag),
        episode: episode,
        kind: kind,
        source: link,
        url: VideoExtractor::UrlExtractor.new(video_tag.text).extract,
        language: :russian,
      )
    end
  end

  # итоговая обработка полученных видео
  def postprocess entry
    entry[:videos] = entry[:videos].compact.select(&:url)
    videos = entry[:videos]

    videos.each {|v| v[:episode] = 1 } if videos.all? {|v| v[:episode].zero? }
    videos.each {|v| v[:author] = entry[:author] if v[:kind] == :fandub } if entry[:author] && videos.none? {|v| v[:author] }

    entry
  end

  def extract_year content
    content =~ /Год выпуска.*?(?<year>\d+)/ && $~[:year].to_i
  end

  def extract_global_author content
    content =~ /Озвучено:(?<author>.+)/ && $~[:author].gsub(/<.*?>/, '').strip
  end

  def extract_episodes_num content
    content =~ /Серии.*?из.*?(?<episodes_num>\d+)( эп.|<br)/ && $~[:episodes_num].to_i
  end

  def extract_categories content
    if content =~ /Категория:(?<category>.+)/
      $~[:category]
        .gsub(/<.*?>/, '')
        .strip
        .split(',')
        .map {|v| v.sub(/\(.*?\)/, '').strip }
        .uniq
    end
  end

  def extract_kind meta
    case meta
      when /[сc]убтитры|рус.? ?суб/i then :subtitles
      else :fandub
      #when /озвучка|озвучено|озвучил/i then :fandub
      #when /^(муви|сибнет|myvi|sibnet|cпэшл|бонус|первый том|второй том|part one.*|part two.*|)$/i then :unknown
      #else :fandub
    end
  end

  def extract_author meta, name_tag
    span_tag = name_tag.css('span').first
    author = if span_tag
      span_tag
        .text
    else
      meta || ''
    end

    author = author
      .strip
      .gsub(/^[\(\[-]|[\)\]-]$/, '')
      .gsub(/sibnet|сибнет|myvi|муви/i, '')
      .strip
      .gsub(/^[\(\[-]|[\)\]-]$/, '')
      .gsub(/(?:озвучка|озвучено|озвучил|[сc]убтит?ры|рус. ?суб.):? ?(?:от )?/i, '')
      .gsub(/^[\(\[-]|[\)\]-]$/, '')
      .strip

    author == '' ? nil : author
  end

private
  # страница каталога сайта
  def catalog_url page
    "http://www.animespirit.ru/page/#{page}/"
  end

  # загрузка страницы через прокси
  def get url, required_text=@required_text
    Proxy.get(
      url,
      timeout: 30,
      required_text: required_text,
      ban_texts: required_text.present? ? nil : MalFetcher.ban_texts,
      no_proxy: @no_proxy,
      log: @proxy_log
    )
  end
end
