# rubocop:disable all
require 'thread_pool'

# http://pastebin.com/r2Xz6i0M
class ProxyParser
  TEST_URL = "https://shikimori.one#{ProxyTest::TEST_PAGE_PATH}"
  WHAT_IS_MY_IP_URL = "https://#{Shikimori::DOMAINS[:production]}#{ProxyTest::WHAT_IS_MY_IP_PATH}"

  # HIDEME_URL = "http://hideme.ru/api/proxylist.php?out=js&code=253879821"

  # импорт проксей
  def import
    proxies = fetch
    save proxies
  end

  # парсинг проксей из внешних источников
  def fetch
    parsed_proxies = parse_proxies
    raise "only #{parsed_proxies.size} were found" if parsed_proxies.size < 2000

    print format("found %<size>i proxies\n", size: parsed_proxies.size)

    proxies = (Proxy.all.map { |v| { ip: v.ip, port: v.port } } + parsed_proxies)
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
    proxies = OpenURI.open_uri(url).read.gsub(/\d+\.\d+\.\d+\.\d+:\d+/).map do |v|
      data = v.split(':')

      { ip: data[0], port: data[1] }
    end
    print "#{url} - #{proxies.size} proxies\n"

    proxies
  rescue StandardError => e
    print "#{url}: #{e.message}\n"
    []
  end

  # проверка проксей на работоспособность
  def test proxies, ip
    verified_proxies = []

    print "testing #{proxies.size} proxies\n"

    proxies.parallel(threads: 750, timeout: 15) do |proxy|
      verified_proxies << proxy if anonymouse?(proxy, ip)
    end

    verified_proxies
  end

  # анонимна ли прокся?
  def anonymouse? proxy, ip
    content = Proxy.get(TEST_URL, timeout: 10, proxy: proxy)
    content&.include?(ProxyTest::SUCCESS_CONFIRMATION_MESSAGE) && !content.include?(ip)
  rescue *::Network::FaradayGet::NET_ERRORS
    false
  end

  # источники проксей
  def sources
    @sources ||= SOURCES + webanetlabs + proxy_24
    # + rebro_weebly
    # Nokogiri::HTML(open('http://www.italianhack.org/forum/proxy-list-739/').read).css('h3.threadtitle a').map {|v| v.attr :href }
  end

  def webanetlabs
    Nokogiri::HTML(open('https://webanetlabs.net/publ/24').read)
      .css('.uSpoilerText a.link')
      .map { |v| 'https://webanetlabs.net' + v.attr(:href) }
  rescue StandardError => e
    print "webanetlabs: #{e.message}\n"
    []
  end

  # def rebro_weebly
  #   # 20 proxies
  #   Nokogiri::HTML(open('http://rebro.weebly.com/txt-lists.html').read)
  #     .css('a')
  #     .map { |v| v.attr :href }
  #     .uniq
  #     .select { |v| v =~ /\.txt$/ }
  #     .map { |v| 'http://rebro.weebly.com' + v }
  # end

  def proxy_24 url = 'http://www.proxyserverlist24.top', nesting = 0
    return [] unless url

    html = Nokogiri::HTML(OpenURI.open_uri(url).read)

    links = html.css('.post-title.entry-title a').map { |v| v.attr :href }

    if nesting > 20
      links
    else
      links + proxy_24(html.css('.blog-pager-older-link').first&.attr(:href), nesting + 1)
    end
  end

  def parse_proxies
    sources.map { |url| parse url }.flatten
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
    # 'http://socks.biz.ua/?action=proxylist',

    # 0 / 220
    # 'http://bestproxy.narod.ru/proxy1.html',
    # 'http://bestproxy.narod.ru/proxy2.html',
    # 'http://bestproxy.narod.ru/proxy3.html',

    # 'http://utenti.multimania.it/rjezyd/',
    # 'http://j-s.narod.ru/proxy.htm', 0!

    # 'http://www.proxy-faq.de/80.html',
    # 'http://proxyleecher.tripod.com/',

    # 'http://proxylist.h12.ru/azia.htm',
    # 'http://proxylist.h12.ru/america.htm',

    # 14 / 1000
    # 'http://notan.h1.ru/hack/xwww/proxy1.html',
    # 'http://notan.h1.ru/hack/xwww/proxy2.html',
    # 'http://notan.h1.ru/hack/xwww/proxy3.html',
    # 'http://notan.h1.ru/hack/xwww/proxy4.html',
    # 'http://notan.h1.ru/hack/xwww/proxy5.html',
    # 'http://notan.h1.ru/hack/xwww/proxy6.html',
    # 'http://notan.h1.ru/hack/xwww/proxy7.html',
    # 'http://notan.h1.ru/hack/xwww/proxy8.html',
    # 'http://notan.h1.ru/hack/xwww/proxy9.html',
    # 'http://notan.h1.ru/hack/xwww/proxy10.html'
  ]
end
