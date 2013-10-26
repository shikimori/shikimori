require 'thread_pool'

class ProxyParser
  TestUrl = "http://shikimori.org#{ProxyTest::TestPage}"
  IpUrl ="http://shikimori.org#{ProxyTest::WhatIsMyIpPage}"

  # импорт проксей
  def import
    proxies = fetch
    save proxies
  end

  # парсинг проксей из внешних источников
  def fetch
    parsed_proxies = sources.map { |url| parse(url) }.flatten.uniq
    print "found %i proxies\n" % [parsed_proxies.size]

    proxies = (Proxy.all.map { |v| { ip: v.ip, port: v.port } } + parsed_proxies).uniq.map do |proxy_hash|
      Proxy.new proxy_hash
    end
    print "%i after merge with previously parsed\n" % [proxies.size]

    print "getting own ip... "
    ip = open(IpUrl).read.strip
    print "#{ip}\n"

    verified_proxies = test(proxies, ip)
    print "%i of %i proxies were tested for anonymity\n" % [verified_proxies.size, proxies.size]

    verified_proxies
  end

  # сохранение проксей в базу
  def save(proxies)
    ActiveRecord::Base.transaction do
      if proxies.any?
        Proxy.delete_all
        Proxy.import proxies
      end
    end
  end

private
  # парсинг проксей со страницы
  def parse(url)
    proxies = open(url).read.gsub(/\d+\.\d+\.\d+\.\d+:\d+/).map do |v|
      data = v.split(':')

      { ip: data[0], port: data[1] }
    end
    print "#{url} - #{proxies.size} proxies\n"

    proxies
  rescue Exception => e
    print "#{url}: #{e.message}\n"
    []
  end

  # проверка проксей на работоспособность
  def test(proxies, ip)
    verified_proxies = []

    pbar = ProgressBar.new("testing proxies", proxies.size)

    proxies.parallel(threads: 750, timeout: 15) do |proxy|
      verified_proxies << proxy if anonymouse?(proxy, ip)
      pbar.inc
    end
    pbar.finish

    verified_proxies
  end

  # анонимна ли прокся?
  def anonymouse?(proxy, ip)
    content = Proxy.get(TestUrl, timeout: 10, proxy: proxy)
    content && content.include?(ProxyTest::SuccessConfirmationMessage) && !content.include?(ip)
  end

  # источники проксей
  def sources
    @sources ||= Sources + Nokogiri::HTML(RestClient.get(Proxies24Url)).css('.post-title.entry-title a').map {|v| v.attr('href') }
  end

  Proxies24Url = 'http://proxies24.blogspot.ru/search?max-results=10'

  # http://forum.antichat.ru/thread59009.html
  Sources = [
    'http://www.freeproxy.ch/proxy.txt',
    #'http://elite-proxies.blogspot.com/',
    #'http://eliteanonymous.blogspot.ru/',
    #'http://goodhack.ru/index.php?/topic/1504-fresh-proxy-by-anonymouse/',

    #'http://feeds2.feedburner.com/Socks5UsLive',
    #'http://proxy-heaven.blogspot.com/',
    #'http://socks.biz.ua/?action=proxylist',

    # 0 / 220
    #'http://bestproxy.narod.ru/proxy1.html',
    #'http://bestproxy.narod.ru/proxy2.html',
    #'http://bestproxy.narod.ru/proxy3.html',

    #'http://utenti.multimania.it/rjezyd/',
    #'http://j-s.narod.ru/proxy.htm', 0!

    #'http://www.proxy-faq.de/80.html',
    #'http://proxyleecher.tripod.com/',

    #'http://proxylist.h12.ru/azia.htm',
    #'http://proxylist.h12.ru/america.htm',

    # 14 / 1000
    #'http://notan.h1.ru/hack/xwww/proxy1.html',
    #'http://notan.h1.ru/hack/xwww/proxy2.html',
    #'http://notan.h1.ru/hack/xwww/proxy3.html',
    #'http://notan.h1.ru/hack/xwww/proxy4.html',
    #'http://notan.h1.ru/hack/xwww/proxy5.html',
    #'http://notan.h1.ru/hack/xwww/proxy6.html',
    #'http://notan.h1.ru/hack/xwww/proxy7.html',
    #'http://notan.h1.ru/hack/xwww/proxy8.html',
    #'http://notan.h1.ru/hack/xwww/proxy9.html',
    #'http://notan.h1.ru/hack/xwww/proxy10.html'
  ]
end
