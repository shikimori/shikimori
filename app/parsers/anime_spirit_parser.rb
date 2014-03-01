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
    {
      russian: names.first,
      name: names.second,
      year: content =~ /Год выпуска.*?(?<year>\d+)/ && $~[:year].to_i,
      videos: extract_videos(link, doc.css('.accordion'))
    }
  end

  # выборка видео из nokogiri контента
  def extract_videos link, doc
    doc.css('h3,p').each_slice(3).map do |(name,trash,video)|
      next unless name.text =~ /(?<kind>.*?) (?<episode>\d+)$/

      {
        #kind: $~[:episode],
        episode: $~[:episode].to_i,
        source: link,
        url: video.text
      }
    end
  end

#episode: episode,
#kind: kind,
#language: extract_language(kind && !kind.kind_of?(Symbol) ? kind : description),
#source: url,
#url: video_url,
#author: HTMLEntities.new.decode(author)

private
  # страница каталога сайта
  def catalog_url page
    "http://www.animespirit.ru/page/#{page}/"
  end

  # загрузка страницы через прокси
  def get url, required_text=@required_text
    Proxy.get(url,
              timeout: 30,
              required_text: required_text,
              ban_texts: required_text.present? ? nil : MalFetcher.ban_texts,
              no_proxy: @no_proxy,
              log: @proxy_log)
  end
end
