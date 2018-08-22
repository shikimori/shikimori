class BtjunkieParser < TorrentsParser
  @@btjunkie_rss_url = "http://btjunkie.org/rss.xml?query=%s"
  @@btjunkie_search_anime_url = "http://btjunkie.org/search?q=%s&c=7"
  @@btjunkie_search_url = "http://btjunkie.org/search?q=%s"
  @@nyatorrents_rss_url = "http://www.nyaa.eu/?page=rss&catid=1&subcat=11&term=%s"
  @@nyatorrents_nofilter_rss_url = "http://www.nyaa.eu/?page=rss&term=%s"

  def self.rss(query)
    content = get(@@btjunkie_rss_url % query, '<html>')
    return nil unless content
    return nil if content.include?('<html><head><title>')

    feed = []

    doc = Nokogiri::XML(content)
    doc.xpath('//channel//item').each do |v|
      begin
        attributes = v.xpath('enclosure')[0].attributes
        title = v.xpath('title').inner_html
        item = {
          :guid => attributes['url'].value.sub('dl.btjunkie.org', 'btjunkie.org').sub('/download.torrent', ''),
          :size => attributes['length'].value.to_i/1024/1024,
          #:pubDate => DateTime.parse(v.xpath('pubDate').inner_html)
        }
        item[:link] = "%s/download.torrent" % item[:guid]
        if title.match /(.*?)\s+\[(\d+)\/(\d+)\]$/
          item[:title] = $1
          item[:seed] = $2.to_i
          item[:leech] = $3.to_i
        end
        next if item.keys.size != 6
        next if item[:seed] == 0
        feed << item
      rescue StandardError => e
        raise Interrupt.new if e.class == Interrupt
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
    filter_bad_formats(feed)
  end

  def self.nya_rss(query, filter=:yes)
    content = get((filter == :yes ? @@nyatorrents_rss_url : @@nyatorrents_nofilter_rss_url) % query)

    return nil unless content
    return nil if content.include?('<html><head><title>')

    feed = []

    doc = Nokogiri::XML(content)
    doc.xpath('//channel//item').each do |v|
      begin
        desc = v.xpath('description')[0].inner_html.match(/(\d+) seeder.*(\d+) leecher/)
        item = {
          :title => v.xpath('title')[0].inner_html,
          :link => v.xpath('link')[0].inner_html.gsub('&amp;', '&'),
          :guid => v.xpath('guid')[0].inner_html.gsub('&amp;', '&'),
          :pubDate => DateTime.parse(v.xpath('pubDate')[0].inner_html),
          :seed => desc ? desc[1].to_i : 0,
          :leech => desc ? desc[2].to_i : 0,
        }
        next if item[:seed] == 0
        feed << item
      rescue StandardError => e
        raise Interrupt.new if e.class == Interrupt
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
    feed = filter_bad_formats(feed)
    feed.empty? ? nil : feed
  end


  def self.web(query)
    html(query, @@btjunkie_search_url % query)
  end

  def self.web_anime(query)
    html(query, @@btjunkie_search_anime_url % query)
  end

private
  def self.html(query, url)
    content = get(url)
    return nil unless content
    return nil if content.include?('<html><head><title>')

    feed = []

    doc = Nokogiri::HTML(content)
    doc.css('.tab_results tr[onmouseout]').each do |v|
      begin
        a = v.children[0].css('.BlckUnd')[0]
        item = {
          :guid => 'http://btjunkie.org' + a[:href],
          :link => 'http://dl.btjunkie.org' + a[:href] + '/download.torrent',
          :title => a.inner_html.gsub(/<[^>]+>/, '').strip,
          :size => v.children[4].inner_html.gsub(/<[^>]+>/, '').sub('MB', '').to_i,
          :seed => v.children[8].inner_html.gsub(/<[^>]+>/, '').to_i,
          :leech => v.children[10].inner_html.gsub(/<[^>]+>/, '').to_i
        }
        next if item[:seed] == 0
        feed << item
      rescue StandardError => e
        raise Interrupt.new if e.class == Interrupt
        #puts e.message
        #puts e.backtrace.join("\n")
      end
    end
    feed
  end
end
