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
    doc.css('h3,p').each_slice(3).map do |(name,trash,video)|
      text = name.text.strip

      next if text =~ /^[\[( -]*спешл|pv|трейлер/i
      next if text =~ /временно отсутствует/
      unless text =~ /(?<meta>)(?<episode>\d+)$/ ||
          text =~ /^(?<episode>\d*).*\((?<meta>.+)\)(?: ?(?:\[|-|).+(?:\[|-|))?$/ ||
          text =~ /^(?<episode>\d*).*(?<meta>) (?:\[|-).+(?:\[|-)$/ ||
          text =~ /^(?<episode>\d*).*(?<meta>)$/
        raise "can't parse entry: #{text} [#{link}]"
      end
      meta = $~[:meta].strip
      episode = ($~[:episode] || 0).to_i
      #binding.pry if VideoExtractor::UrlExtractor.new(video.text).extract == "http://myvi.ru/player/flash/oTeXdFuMc_QiH2OnQgziqKVw3m8VsxX-N5zbzTd50s5DufjzYAKc2iI3QDO89xNhn0"
      #binding.pry if VideoExtractor::UrlExtractor.new(video.text).extract.blank?

      ParsedVideo.new(
        author: extract_author(meta, text),
        episode: episode,
        kind: extract_kind(meta.present? ? meta : text),
        source: link,
        url: VideoExtractor::UrlExtractor.new(video.text).extract,
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
      when /озвучка|озвучено|озвучил|рус. ?суб./i then :fandub
      when /[сc]убтитры/i then :subtitles
      #when 'Оригинал' then :raw
      when /^(муви|сибнет|myvi|sibnet|cпэшл|бонус|первый том|второй том|part one.*|part two.*|)$/i then :unknown
      when /.+/i
        puts "can't extract kind: '#{meta}'" unless Rails.env.test?
        :unknown

      else
        raise "unexpected russian kind: '#{meta}'"
    end
  end

  def extract_author meta, text
    case meta
      when /(?:озвучка|озвучено|озвучил|озвучила):? (от )?(.+)/i then $1
      when /^(?:озвучка|озвучено|озвучил|[сc]убтитры|рус. ?суб.|)$/i then nil
      else
        if text =~ /\((?<author>.*)\)/
          $~[:author]
        else
          puts "can't extract author: '#{meta}'" unless Rails.env.test?
          nil
        end
    end
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
