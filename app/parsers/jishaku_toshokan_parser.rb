class JishakuToshokanParser < TorrentsParser
  # выгрузка страницы с тошокана
  def self.get_page(url)
    content = get(url).gsub('<span class="s"> </span>', '')
    doc = Nokogiri::HTML(content)

    feed = []

    trs = doc.css('.main-index-info-cell')
    trs.each do |tr|
      links = tr.css('a')
      feed << {
        title: links[0].text,
        link: links[1].attr('href').gsub('&amp;', '&'),
        guid: links[1].attr('href').gsub('&amp;', '&').sub('download', 'torrentinfo'),
        pubDate: DateTime.parse(tr.css('abbr')[1].attr('title'))
      }
    end
    feed#.sort_by { |v| v[:pubDate] }
  end

private
  def get(url)
    super(url, required_text=['<title>Jishaku Toshokan', '</html>'])
  end
end

