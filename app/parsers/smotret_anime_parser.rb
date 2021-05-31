class SmotretAnimeParser < ServiceObjectBase
  CONFIG_FILE = "#{Rails.root.join}/tmp/cache/links.yml"
  URL_TEMPLATE = 'https://smotret-anime.online/catalog/zzz-'
  MAX_ID = 14_892

  def call
    1.upto(MAX_ID) do |id|
      next if data[id]

      links = extract_links(id)
      data[id] = links

      File.open(CONFIG_FILE, 'w') { |f| YAML.dump data, f } if (id % 100).zero?
    end
  end

private

  def extract_links id
    url = URL_TEMPLATE + id.to_s

    Rails.cache.fetch([id, :links]) do
      html = Rails.cache.fetch(url) { get_page(url) }
      parse_links(html)
    end
  end

  def parse_links html
    Nokogiri::HTML(html).css('.m-catalog-view-links a').map do |node|
      { url: node.attr('href'), text: node.text.strip }
    end
  end

  def get_page url
    connection = Faraday.new do |conn|
      conn.use FaradayMiddleware::FollowRedirects, limit: 5
      conn.adapter Faraday.default_adapter
    end

    response = connection.get(url) do |req|
      req.options[:timeout] = 3
      req.options[:open_timeout] = 3
      req.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) '\
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
    end

    response.body
  rescue Faraday::ConnectionFailed => e
    raise unless e.message == 'execution expired'

    ''
  end

  def data
    @data ||=
      begin
        YAML.load_file CONFIG_FILE
      rescue Errno::ENOENT
        {}
      end
  end
end
