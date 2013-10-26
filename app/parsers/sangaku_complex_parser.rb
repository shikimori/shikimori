class SangakuComplexParser < SiteParserWithCache
  def initialize
    super

    @posts_index_template = "http://idol.sankakucomplex.com/post/index.json?page=%d&tags=cosplay&limit=100"
    @ban_tags = %w{
      censored sex penis vaginal large_breasts anal doggystyle vagina anus uncensored spread_legs cum
      cum_on_leg girl_on_top animated_gif panties_down topless nipples nude onsen bottomless paipan
    } << %w{maid_uniform swimsuit maid}
    @max_page = 831
  end

  # загрузка всех постов с сайта
  def fetch_posts
    cache[:page] ||= 1
    cache[:posts] ||= {}
    begin
      data = fetch_page(cache[:page])
      break if data.empty?
      posts = parse(data)
      print "fetched page %d with %d posts...\n" % [cache[:page], data.size]

      cache[:page] += 1
      cache[:posts].merge! posts
    rescue Interrupt => e
      break# if e.class == Interrupt
      #print "%i\n%s\n%s\n" % [id, e.message, e.backtrace.join("\n"), content]
      #break
    end while !data.empty?
    save_cache
  end

  # загрузка страницы
  def fetch_page(page)
    content = Proxy.get(@posts_index_template % page, no_proxy: true)
    return [] unless content

    data = JSON(content)
  end
  #Time.at

  def parse(data)
    data.inject({}) do |rez,v|
      v['created_at'] = Time.at(v['created_at']['s'])
      rez[v['id']] = v
      rez
    end
  end
  # преобразует полученные данные с сайта в нужный формат
end
