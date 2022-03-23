# rubocop:disable all

# http://pastebin.com/r2Xz6i0M
class ProxyParser
  TEST_URL = "https://shikimori.one#{ProxyTest::TEST_PAGE_PATH}"
  CACHE_VERSION = :v5

  # HIDEME_URL = "http://hideme.ru/api/proxylist.php?out=js&code=253879821"

  # импорт проксей
  def import
    proxies = fetch
    save proxies
  end

  # парсинг проксей из внешних источников
  def fetch
    parsed_proxies = parse_proxies is_url_sources: true, is_custom_sources: true
    db_proxies = Proxy.all.map { |v| { ip: v.ip, port: v.port } }

    # parsed_proxies.each {|v| puts "#{v[:ip]}:#{v[:port]}" }

    print format("found %<size>i proxies\n", size: parsed_proxies.size)
    print format("fetched %<size>i proxies\n", size: db_proxies.size)

    proxies = (db_proxies + parsed_proxies)
      .uniq
      .map { |proxy_hash| Proxy.new proxy_hash }
    print format("%<size>i after merge with previously parsed\n", size: proxies.size)

    print 'getting own ip... '
    ip = OpenURI.open_uri(WHAT_IS_MY_IP_URL).read.strip
    print "#{ip}\n"

    verified_proxies = test(proxies, ip)
    print(
      format(
        "%<verified_size>i of %<total_size>i proxies were tested for anonymity\n",
        verified_size: verified_proxies.size,
        total_size: proxies.size
      )
    )

    verified_proxies
  end

  # сохранение проксей в базу
  def save proxies
    ApplicationRecord.transaction do
      if proxies.any?
        Proxy.delete_all
        Proxy.import proxies
      end
    end
  end

private

  # парсинг проксей со страницы
  def parse url
    # задержка, чтобы не нас не банили
    sleep 1
    proxies = OpenURI.open_uri(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      .read
      .gsub(/\d+\.\d+\.\d+\.\d+:\d+/)
      .map do |v|
        data = v.split(':')

        { ip: data[0], port: data[1].to_i }
      end
    print "#{url} - #{proxies.size} proxies\n"

    proxies
  rescue StandardError => e
    print "#{url}: #{e.message}\n"
    []
  end

  # проверка проксей на работоспособность
  def test proxies, ip
    proxies = proxies
    verified_proxies = Concurrent::Array.new

    print "testing #{proxies.size} proxies\n"

    pool = Concurrent::FixedThreadPool.new(Concurrent.processor_count * 20)
    index = Concurrent::AtomicFixnum.new(-1)

    proxies.each do |proxy|
      pool.post do
        current_index = index.increment
        puts "testing #{current_index}/#{proxies.size} proxy #{proxy}"

        verified_proxies << proxy if anonymouse?(proxy, ip)
      end
    end

    loop do
      sleep 2
      break if pool.queue_length.zero?
    end
    pool.kill

    verified_proxies
  end

  # анонимна ли прокся?
  def anonymouse? proxy, ip
    content = Proxy.get(TEST_URL, timeout: 10, proxy: proxy)
    content&.include?(ProxyTest::SUCCESS_CONFIRMATION_MESSAGE) &&
      ips.none? { |ip| content.include? ip }
  rescue *::Network::FaradayGet::NET_ERRORS
    false
  end

  # источники проксей
  def url_sources
    @url_sources ||= Rails.cache.fetch([:proxy, :sources, CACHE_VERSION], expires_in: 1.hour) do
      SOURCES + webanetlabs # + proxy_24
    end
  end

  def custom_soruces
    []
    # %i[openproxy_space]
  end

  def webanetlabs
    Nokogiri::HTML(
      OpenURI.open_uri(
        'https://webanetlabs.net/publ/24',
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      ).read
    )
      .css('.uSpoilerText a.link')
      .map { |v| 'https://webanetlabs.net' + v.attr(:href) }
  rescue StandardError => e
    print "webanetlabs: #{e.message}\n"
    []
  end

  # def proxy_24 url = 'http://www.proxyserverlist24.top', nesting = 0
  #   return [] unless url
  #
  #   html = Nokogiri::HTML(OpenURI.open_uri(url).read)
  #
  #   links = html.css('.post-title.entry-title a').map { |v| v.attr :href }
  #
  #   if nesting > 20
  #     links
  #   else
  #     links + proxy_24(html.css('.blog-pager-older-link').first&.attr(:href), nesting + 1)
  #   end
  # end

  # all proxies are broken
  # def openproxy_space
  #   # index_url = "https://api.openproxy.space/list?skip=0&ts=#{Time.zone.now.to_i}000"
  #   # json = JSON.parse OpenURI.open_uri(index_url).read, symbolize_names: true
  #   # codes = json.select { |v| v[:title].match? /http/i }.map { |v| v[:code] }
  #   #
  #   # codes.flat_map do |code|
  #     # url = "https://api.openproxy.space/list/#{code}"
  #     url = 'https://api.openproxy.space/lists/http'
  #     json = JSON.parse OpenURI.open_uri(url).read, symbolize_names: true
  #     proxies = json[:data].flat_map do |v|
  #       v[:items].map do |vv|
  #         data = vv.split(':')
  #         { ip: data[0], port: data[1].to_i }
  #       end
  #     end
  #     print "#{url} - #{proxies.size} proxies\n"
  #     proxies
  #   # end
  # end

  def parse_proxies is_url_sources:, is_custom_sources:
    url_sourced_proxies = is_url_sources ?
      url_sources.flat_map do |url|
        Rails.cache.fetch([url, :proxies, CACHE_VERSION]) { parse url }
      end : []

    custom_sourced_proxies = is_custom_sources ?
      custom_soruces.flat_map do |method|
        Rails.cache.fetch([method, :proxies, CACHE_VERSION]) { send method }
      end : []

    (url_sourced_proxies + custom_sourced_proxies).uniq
    # source_proxies = sources.map { |url| parse url }.flatten
    # hideme_proxies = JSON.parse(open(HIDEME_URL).read).map do |proxy|
      # { ip: proxy['ip'], port: proxy['port'].to_i }
    # end

    # (source_proxies + hideme_proxies).uniq
  end

  # Proxies24Url = 'http://www.proxies24.org/'
  # Proxies24Url = 'http://proxy-server-free.blogspot.ru/'

  # http://forum.antichat.ru/thread59009.html
  SOURCES = [
    # 'https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=10000&country=all&ssl=all&anonymity=elite&simplified=true&limit=300'
    # 'http://alexa.lr2b.com/proxylist.txt',
    # 'http://multiproxy.org/txt_all/proxy.txt', # 0 of 1526
    # 'http://txt.proxyspy.net/proxy.txt', # 53 of 202
    # 'http://rebro.weebly.com/proxy-list.html', # 1 of 22
    # 'http://www.prime-speed.ru/proxy/free-proxy-list/elite-proxy.php', # 1 of 157
    # 'http://www.prime-speed.ru/proxy/free-proxy-list/all-working-proxies.php', # 1 of 958
    # 'http://www.prime-speed.ru/proxy/free-proxy-list/anon-elite-proxy.php', # 0 of 354
    # 'http://www.cybersyndrome.net/pla.html',

    # 'http://www.freeproxy.ch/proxy.txt',
    # 'http://elite-proxies.blogspot.com/',
    # 'http://eliteanonymous.blogspot.ru/',
    # 'http://goodhack.ru/index.php?/topic/1504-fresh-proxy-by-anonymouse/',

    # 'http://feeds2.feedburner.com/Socks5UsLive',
    # 'http://proxy-heaven.blogspot.com/',
  ]
end
