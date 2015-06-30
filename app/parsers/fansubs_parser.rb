# парсер и импортер ссылок на субтитры с fansubs.ru
class FansubsParser
  SearchUrl = "http://fansubs.ru/search.php"
  ArchiveUrl = "http://fansubs.ru/base.php?id=%d"
  ForumUrl = "http://fansubs.ru/forum/viewtopic.php?t=%d"
  DownloadUrl = "http://fansubs.ru/forum/download.php?id=%d"

  attr_accessor :proxy_log, :use_proxy

  # конструктор
  def initialize
    @proxy_log = Rails.env == 'development' ? true : false
    @use_proxy = true#Rails.env == 'development' ? false : true
  end

  # импорт субтитров для аниме
  def import(anime)
    data = nil
    TorrentsMatcher.new(anime).name_variants.each do |query|
      data = find_subtitles(query.gsub(/[^0-9A-Za-z А-Яа-я]/, ' ').gsub(/ +/, ' '), anime)

      if data.present?
        BlobData.set("anime_#{anime.id}_subtitles", data) unless data.empty?
        return data
      end
    end
    nil
  end

  # поиск субтитров на fansubs.ru
  def find_subtitles(query, anime)
    content = post(SearchUrl, {query: query})
    return nil unless content

    doc = Nokogiri::HTML(content)
    entries = doc.css('li a')
      .map { |node| extract_entry node }
      .compact
      .select do |entry|
        (entry[:type].nil? || entry[:type] == anime.kind) &&
          TorrentsMatcher.new(anime).matches_for(entry[:title])
      end

    entries.map do |entry|
      extract_subtitles(entry)
    end.compact.each_with_object({}) do |feed, rez|

      hash = Digest::MD5.hexdigest(feed[:title])
      while rez[hash]
        feed[:title] += ' '
        hash = Digest::MD5.hexdigest(feed[:title])
      end

      rez[hash] = feed if feed[:feed].any?
    end
  end

private

  # выборка из Nokogiri Node записи об элементе
  def extract_entry(node)
    if node[:href].match(/t=(\d+)/)
      id = $1.to_i
      inner_html = cp1251_to_utf8(node.inner_html)

      title = inner_html.gsub(/<.*?>|\(.*?\)/, '').strip
      {
        id: id,
        title: HTMLEntities.new.decode(title)#,
        #type: type
      }
    elsif node[:href].match(/id=(\d+)/)
      id = $1.to_i
      inner_html = cp1251_to_utf8(node.inner_html)
      type = inner_html.match(/<small>\(?(.*?)\)?<\/small>/)[1]
        .sub('ТВ', 'tv')
        .sub(/Спецвыпуск|Cпецвыпуск/, 'special')
        .sub('Фильм', 'movie')
      title = inner_html.gsub(/<.*?>|\(.*?\)/, '').strip
      {
        id: id,
        title: HTMLEntities.new.decode(title),
        type: type.to_sym,
        link: ArchiveUrl % id
      }
    end

  rescue Exception => e
    raise e if e.class == Interrupt
    print "#{e.message}\n#{e.backtrace.join("\n")}\n"
    nil
  end

  # выборка субтитров из списка страниц
  def extract_subtitles(entry)
    if entry[:link] != nil
      feed = {
        title: entry[:title],
        link: entry[:link],
        feed: []
      }

      content = get(feed[:link])
      doc = Nokogiri::HTML(content)
      doc.css('table table').each do |table|
        next unless table[:class] == nil
        next unless table[:width] == "750"
        tds = table.css('tr td')
        item = {
          title: HTMLEntities.new.decode(cp1251_to_utf8(tds[2].inner_html.gsub(/<.*?>/, ''))),
          type: HTMLEntities.new.decode(cp1251_to_utf8(tds[3].inner_html.gsub(/<.*?>/, '')))
        }
        feed[:feed] << item
      end
    else
      feed = {
        title: entry[:title],
        feed: []
      }

      content = get(ForumUrl % entry[:id])
      doc = Nokogiri::HTML(content)
      doc.css('tr > td > span[class=gen] a').each do |link|
        item = {
          link: DownloadUrl % link[:href].match(/\d+$/)[0],
          title: HTMLEntities.new.decode(cp1251_to_utf8(link.inner_html))
        }
        feed[:feed] << item
      end
    end

    feed

  rescue Exception => e
    raise e if e.class == Interrupt
    print "#{e.message}\n#{e.backtrace.join("\n")}\n"
    nil
  end

  def cp1251_to_utf8(text)
    text.encoding.name == 'Windows-1251' ? text.encode('utf-8') : text
  end

  def get(url)
    Proxy.get(url, encoding: 'windows-1251', timeout: 15, log: @proxy_log, required_text: ['Kage Project', '</html>'], no_proxy: !@use_proxy)
  end

  def post(url, data)
    Proxy.post(url, encoding: 'windows-1251', data: data, timeout: 15, log: @proxy_log, required_text: ['Kage Project', '</html>'], no_proxy: !@use_proxy)
  end
end
