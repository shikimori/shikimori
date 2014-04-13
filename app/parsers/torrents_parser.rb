class TorrentsParser
  PROXY_LOG = ENV['RAILS_ENV'] == 'development' ? true : false
  USE_PROXY = false#ENV['RAILS_ENV'] == 'development' ? false : true

  cattr_accessor :with_proxy

  # игнорируемые названия торрентов
  IgnoredTorrents = Set.new [
    'Chuunibyou demo Koi ga Shitai! Lite - 04 (640x360 x264 AAC).mp4',
    '[WZF]Ore_no_Imouto_ga_Konna_ni_Kawaii_Wake_ga_Nai_-_Capitulo_13-15[BDRip][X264-AAC][1280x720][Sub_Esp]',
    'Owari Subs] Mahouka Koukou no Rettousei ~ Esplorando Mahouka 03 [Webrip][207F8116].mkv',
    '[iPUNISHER] Mahouka Koukou No Rettousei - Yoku Wakaru Mahouka - 03 [720p][AAC].mkv'
  ]
  # аниме, для которых не будут искаться торренты
  AnimeIgnored = [13185, 19207, 5042, 17249, 11457, 21729]

  AnimeWithOnlyNameMatch = [10049, 10033, 6336, 11319]
  AnimeWithExactNameMatch = [10161, 10490, 10379, 6336, 11319, 14645, 15085, 14967, 15611, 17705, 15699, 16241, 16049]
  AnimeWithAllSubGroups = [9539, 12979, 13163, 6702, 15417]

  EPISODE_FOR_HISTORY_REGEXES = [
    /
      [\w!~?\.\)] # завершающий кусочек названия
      (?: _- )?
      _
      \#?
      (?:Vol\.)?
      (?:CH-)?
      (\d+) # номер эпизода
      (?:v[0-3] )? # v0 v1 v2 - версия релиза
      (?: _- )?
      ( _rev\d )?
      ( _RAW | _END )?
      ( # различные варианты концовки
        _
        (
            \[(1080|720|480)p\] _? \[ .*
          |
            (\( | \[) [\w _-]{2,8} (1280|1920)x .*
          |
            \[\w{8}\]
          |
            (\( | \[)
              ( ([\w-]{2,4}_)? \d{3} | [A-Z])
            .*
        )
      )?
      \. (?: mp4 | mp3 | mkv | avi )
      $
    /imx,
  ]
  EPISODES_FOR_HISTORY_REGEXES = [
    /Vol\.(\d+)-(\d+)_(?:\[|\()(?:BD|DVD)/i,
    /[\w\)!~-]_(\d+)-(\d+)(?:_RAW|_END)?_?(?:\(|\[)(?:\d{3}|[A-Z])/i,
    /[\w\)!~-]_(\d+)-(\d+)_\[(?:DVD|BD|ENG|JP|JAP)/i
  ]
  EPISODES_WITH_COMMA_FOR_HISTORY_REGEXES = [
    /[\w\)!~-]_(\d+)-(\d+),_?(\d+)_raw_720/i
  ]

  def self.extract_episodes_num(episode_name)
    return [] if IgnoredTorrents.include?(episode_name)
    num = parse_episodes_num(episode_name).select {|v| v < 1000 }

    # для гинтамы особый фикс
    if episode_name =~ /gintama/i
      num.map {|v| v - 252 }
    elsif episode_name =~ /cardfight!![ _]vanguard/i && episode_name =~ /link[ _]joker/i
      num.map {|v| v - 104 }
    elsif episode_name =~ /Yu-Gi-Oh![ _]Zexal[ _]II/i
      num.map {|v| v - 73 }
    elsif episode_name =~ /kuroko[ _]no[ _](basuke|basket)/i
      num.map {|v| v > 25 ? v - 25 : v }
    elsif episode_name =~ /fairy[ _]?tail/i
      num.map {|v| v > 175 ? v - 175 : v }
    elsif episode_name =~ /kyousou[ _]?giga/i
      num.map {|v| v + 1 }
    else
      num
    end.select {|v| v > 0 }
  end

  def self.parse_episodes_num(episode_name)
    fixed_name = episode_name.gsub ' ', '_'
    EPISODE_FOR_HISTORY_REGEXES.each do |regex|
      return [$1.to_i] if fixed_name.match(regex)
    end
    EPISODES_FOR_HISTORY_REGEXES.each do |regex|
      return (($1.to_i)..($2.to_i)).to_a if fixed_name.match(regex)
    end
    EPISODES_WITH_COMMA_FOR_HISTORY_REGEXES.each do |regex|
      return (($1.to_i)..($2.to_i)).to_a << $3.to_i if fixed_name.match(regex)
    end
    []
  end

  # выгрузка торрентов онгоигов
  def self.grab_ongoings(test=false, anime_id=nil)
    parse_feed(get_rss, anime_id)
  end

  # выгрузка торрентов c конкретной страницы
  def self.grab_page(url, anime_id=nil)
    parse_feed(get_page(url), anime_id)
  end

  # выгрузка rss ленты с тошокана
  def self.get_rss
    content = get(rss_url)

    doc = Nokogiri::XML(content)
    feed = doc.xpath('//channel//item').map do |v|
      category = v.xpath('category')[0]
      next if category && category.inner_html =~ /^(?:English-scanlated Books|Raw Books)$/
      {
        title: v.xpath('title')[0].inner_html,
        link: v.xpath('link')[0].inner_html.gsub('&amp;', '&'),
        guid: v.xpath('guid')[0].inner_html.gsub('&amp;', '&'),
        pubDate: DateTime.parse(v.xpath('pubDate')[0].inner_html),
      }
    end.compact

    filter_bad_formats(feed)
  end

  # парсинг фида тошока
  def self.parse_feed(feed, anime_id)
    print "fetched %d torrens\n" % feed.size
    return 0 if feed.empty?

    animes = if anime_id != nil
      [Anime.find(anime_id)]
    else
      get_ongoings
    end

    animes.sum do |anime|
      matches = feed.select do |v|
        unless AnimeWithAllSubGroups.include?(anime.id) # некоторые аниме только эти негодяи сабят
          next if v[:title].include? '[KRT]' # эти негодяи совсем криво торренты именуют
          next if v[:title].include? '[Arabic]' # это вообще какие-то неадекваты
        end
        next if v[:title].include?('Otome') && v[:title].include?('Amnesia') # оно уже закончилось, но портит хизнь для Amnesia

        anime.matches_for(v[:title],
                          only_name: AnimeWithOnlyNameMatch.include?(anime.id),
                          exact_name: AnimeWithExactNameMatch.include?(anime.id)
                         )
      end

      matches.any? ? add_episodes(anime, matches) : 0
    end
  end

  # выгрузка онгоингов из базы
  def self.get_ongoings
    ongoings = Anime.ongoing.to_a

    anons = Anime
      .where(AniMangaStatus.query_for('planned'))
      .where(kind: ['TV', 'ONA'])
      .where(episodes_aired: 0)
      .includes(:anime_calendars)
      .where('anime_calendars.episode = 1 and anime_calendars.start_at < now()')
      .to_a

    anons.delete_if { |v| v.kind == 'ONA' && v.anime_calendars.empty? }

    released = Anime
      .where("released_on >= ?", DateTime.now - 2.weeks)
      .where("episodes_aired >= 5")
      .to_a

    (ongoings + anons + released).select do |v|
      v.kind != 'Special' && !Anime::EXCLUDED_ONGOINGS.include?(v.id) && !TorrentsParser::AnimeIgnored.include?(v.id)
    end
  end

  # добавление эпизода к аниме
  def self.add_episodes(anime, feed)
    new_episodes = anime.check_aired_episodes(feed)
    unless new_episodes.empty?
      print "%d new episodes(s) found for %s\n" % [new_episodes.size, anime.name]
      anime.torrents = (anime.torrents + new_episodes).uniq {|v| v[:title] }
      new_episodes.size
    else
      new_torrents = feed.select {|v| v[:title].match(/x720|x768|720p|x400|400p|x480|480p|x1080|1080p/) }
      unless new_torrents.empty?
        torrents_before = anime.torrents
        torrents_after = ((torrents_before.is_a?(String) ? [] : torrents_before) + new_torrents).
                           select {|v| v.kind_of?(Hash) && v[:title] }.
                           uniq {|v| v[:title] }
        if torrents_before.size != torrents_after.size
          print "%d new torrent(s) found for %s\n" % [torrents_after.size - torrents_before.size, anime.name]
          anime.torrents = torrents_after
        end
      end
      0
    end
  end

  def self.filter_bad_formats(feed)
    feed.select {|v| v[:title].match(/(?:avi|mkv|mp4|\]|[^\.]{5})$/) }
  end

private
  def self.get(url, ban_texts=nil)
    Proxy.get(url, timeout: 30, ban_texts: ban_texts || MalFetcher.ban_texts, log: PROXY_LOG, no_proxy: !(@@with_proxy.nil? ? USE_PROXY : @@with_proxy))
  end
end
