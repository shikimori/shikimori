class TokyoToshokanParser < TorrentsParser
  # адрес ленты
  def self.rss_url
    'http://www.tokyotosho.info/rss.php'
  end

  # выгрузка страницы с тошокана
  def self.get_page url
    content = get(url).gsub('<span class="s"> </span>', '')
    doc = Nokogiri::HTML(content)

    feed = []

    trs = doc.css('.listing tr').select { |v| v.attr('class').present? } # при одном потомке у первого элемента - это строка о кеше
    trs.each_slice(2) do |first, second|
      next unless first.children[1]

      link = first.children[1].css('a')[1]
      feed << {
        title: link.text,
        link: link.attr('href').gsub('&amp;', '&'),
        guid: link.attr('href').gsub('&amp;', '&').sub('download', 'torrentinfo'),
        pubDate: DateTime.parse(second.children[0].text.match(/Date: (.*?)($| \|)/)[1])
      }
    end

    feed #  .sort_by { |v| v[:pubDate] }
  end

private

  def get url
    super(url, required_text = ['<title>Tokyo Toshokan', '</html>']) ||
      raise(EmptyContentError, url)
  end
end
