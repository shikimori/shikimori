class AnimeSpiritParser
  LEFT_SEPARATOR = /[\[(-]/.source
  RIGHT_SEPARATOR = /[\])-]/.source

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
    if names.size > 2 && (names.size%2).zero?
      size = names.size
      raw_names = block.css('h2 a').first.text.split('/')
      names = [raw_names[0, size/2].join('/'), raw_names[size/2, size].join('/')].map(&:strip)
    end

    postprocess(
      id: link,
      russian: names.first,
      name: names.second,
      names: names,
      year: extract_year(content),
      videos: extract_videos(link, doc.css('.accordion')),
      categories: extract_categories(content) + extract_genres(content),
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
          text =~ /^(?:эпизод )?(?<episode>\d*).*?\((?<meta>.+?)\)(?: ?#{LEFT_SEPARATOR}?.+#{RIGHT_SEPARATOR})?$/i ||
          text =~ /^(?:эпизод )?(?<episode>\d*).*(?<meta>) #{LEFT_SEPARATOR}.+#{RIGHT_SEPARATOR}$/i ||
          text =~ /^(?:эпизод )?(?<episode>\d*).*(?<meta>)$/i
        raise "can't parse entry: #{text} [#{link}]"
      end
      meta = $~[:meta].strip
      episode = ($~[:episode] || 0).to_i
      kind = extract_kind meta.present? ? meta : text
      #binding.pry if VideoExtractor::UrlExtractor.new(video_tag.text).extract == "http://video.sibnet.ru/shell.swf?videoid=1195426"
      #binding.pry if VideoExtractor::UrlExtractor.new(video_tag.text).extract.blank?

      ParsedVideo.new(
        author: extract_author(meta, name_tag),
        episode: episode,
        kind: kind,
        source: link,
        url: VideoExtractor::UrlExtractor.call(video_tag.text),
        language: :russian,
      )
    end
  end

  # итоговая обработка полученных видео
  def postprocess entry
    entry[:videos] = entry[:videos].compact.select(&:url)
    videos = entry[:videos]

    videos.each { |v| v[:episode] = 1 } if videos.all? { |v| v[:episode].zero? }
    videos.each { |v| v[:author] = entry[:author] if v[:kind] == :fandub } if entry[:author] && videos.none? {|v| v[:author] }
    videos.each do |v|
      v[:author] = nil if v[:author] && (v[:author].size > 70 || v[:author] =~ /^\d+/ || v[:author] =~ /\d+-\d+/ || v[:author] =~ /^[^A-zА-я]+$/)
    end

    authors = videos.map {|v| v[:author] }.uniq.size
    episodes = videos.map {|v| v[:episode] }.uniq.size
    videos.each { |v| v[:author] = nil } if authors > episodes/2 && episodes >= 12

    binding.pry if Rails.env.development? && entry[:year] && (entry[:year] < 1900 && entry[:year] > DateTime.now.year + 5.years)

    entry
  end

  def extract_year content
    if content =~ /Год выпуска.*?\d{1,2}\.\d{1,2}\.(?<year>\d+{4})/
      $~[:year].to_i
    elsif content =~ /Год выпуска.*?(?<year>\d+)/
      $~[:year].to_i
    end
  end

  def extract_global_author content
    if content =~ /Озвучено:(?<author>.+)/
      $~[:author]
        .gsub(/<.*?>/, '')
        .strip
        .gsub(/^\(([^\n()]+)\)$/, '\1')
    end
  end

  def extract_episodes_num content
    content =~ /Серии.*?из.*?(?<episodes_num>\d+)( эп.|<br)/ && $~[:episodes_num].to_i
  end

  def extract_categories content
    if content =~ /Категория:(?<category>.+)/
      $~[:category].downcase.gsub(/<.*?>/, '').strip.split(',').map {|v| v.sub(/\(.*?\)/, '').strip }.uniq
    else
      []
    end
  end

  def extract_genres content
    if content =~ /Жанр:(?<genres>.+)/
      $~[:genres].downcase.gsub(/<.*?>/, '').strip.split(',').map(&:strip).uniq
    else
      []
    end
  end

  def extract_kind meta
    case meta
      when /[сc]убтитры|рус.? ?суб/i then :subtitles
      else :fandub
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
      .gsub(/#{LEFT_SEPARATOR}?(sibnet|сибнет|myvi|муви|rutube|рутуб)#{RIGHT_SEPARATOR}?/i, '')
      .gsub(/#{LEFT_SEPARATOR}?(?:озвучка|озвучивание|озвучено|озвучил|[сc]убтит?ры|рус. ?суб.)#{RIGHT_SEPARATOR}?:? ?(?:от )?/i, '')
      .strip
      .gsub(/^#{LEFT_SEPARATOR}|#{RIGHT_SEPARATOR}$/, '')
      .strip

    return nil if author.blank?
    return nil if author.downcase.start_with?('филлер')
    author
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
