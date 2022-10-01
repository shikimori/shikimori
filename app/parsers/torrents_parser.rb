# frozen_string_literal: true

# TODO: refactoring & add specs
class TorrentsParser
  PROXY_LOG = Rails.env.development?
  USE_PROXY = false # ENV['RAILS_ENV'] == 'development' ? false : true

  IGNORED_TORRENTS = Set.new [
    'Chuunibyou demo Koi ga Shitai! Lite - 04 (640x360 x264 AAC).mp4',
    '[WZF]Ore_no_Imouto_ga_Konna_ni_Kawaii_Wake_ga_Nai_-_Capitulo_13-15' \
      '[BDRip][X264-AAC][1280x720][Sub_Esp]',
    'Owari Subs] Mahouka Koukou no Rettousei ~ Esplorando Mahouka 03 [Webrip][207F8116].mkv',
    '[iPUNISHER] Mahouka Koukou No Rettousei - Yoku Wakaru Mahouka - 03 [720p][AAC].mkv',
    '[모에-Raws] Kuzu no Honkai #04 (CX 1280x720 x264 AAC).mp4'
  ]
  IGNORED_PHRASES = [
    %w[Flying Witch Petit],
    %w[Tompel Fansub]
  ]

  ANIME_WITH_NAME_MATCH_ONLY = [10_049, 10_033, 6336, 11_319]
  ANIME_WITH_ALL_SUB_GROUPS = [9539, 12_979, 13_163, 6702, 15_417]

  END_OF_NAME = /[\w()_!~?.+-‒]+/
  EPISODE_FOR_HISTORY_REGEXES = /
    #{END_OF_NAME} # last part of name
    (?: _- )?
    _
    \#?
    (?:Vol\.)?
    (?:CH-)?
    (\d+) # episode name
    (?: _-_Part_\d )?
    (?: v[0-3] )? # v0 v1 v2 - release version
    (?: _ \( \d{1,3} \) )? # additional episode number in brackets
    [_-]*
    (?: _rev\d )?
    (?: _RAW | _END )?
    (?: # different endings
      [_-]+
      (?:
          \[(1080|720|480)p\] _? \[ .*
        |
          (?: \(|\[ ) [\w _-]{2,8} (?: 1280|1920 )x .*
        |
          \[\w{8}\]
        |
          (?: \(|\[ )
            (?: (?: [\w-]{2,4}_ )? \d{3} | [A-Z] )
          .*
      )
    )?
    \. (?: mp4 | mp3 | mkv | avi )
    $
  /mix
  EPISODES_FOR_HISTORY_REGEXES = [
    /Vol\.(\d+)-(\d+)_(?:\[|\()(?:BD|DVD)/i,
    /#{END_OF_NAME}_(\d+)-(\d+)(?:_RAW|_END)?_?(?:\(|\[)(?:\d{3}|[A-Z])/i,
    /#{END_OF_NAME}_(\d+)-(\d+)_\[(?:DVD|BD|ENG|JP|JAP)/i,
    /#{END_OF_NAME}_\((\d+)-(\d+)\)_\[(1080|720|480)p\]/i
  ]
  EPISODES_WITH_COMMA_FOR_HISTORY_REGEXES = [
    /#{END_OF_NAME}_(\d+)-(\d+),_?(\d+)_raw_720/i
  ]

  def self.extract_episodes_num episode_name
    return [] if IGNORED_TORRENTS.include? episode_name
    return [] if ignored_phrases? episode_name

    num = parse_episodes_num(episode_name).select { |v| v < 2000 }

    if episode_name =~ /cardfight!![ _]vanguard/i && episode_name =~ /link[ _]joker/i
      num.map { |v| v - 104 }
    elsif /THE iDOLM@STER Cinderella Girls/i.match?(episode_name)
      num.map { |v| v - 13 }
    elsif /Yu-Gi-Oh![ _]Zexal[ _]II/i.match?(episode_name)
      num.map { |v| v - 73 }
    elsif /stardust[ _]crusaders/i.match?(episode_name)
      num.map { |v| v > 24 ? v - 24 : v }
    elsif /kuroko[ _]no[ _](basuke|basket)/i.match?(episode_name)
      num.map { |v| v > 25 ? v - 25 : v }
    elsif /fairy[ _]?tail/i.match?(episode_name)
      num.map { |v| v > 175 ? v - 175 : v }
    elsif /kyousou[ _]?giga/i.match?(episode_name)
      num.map { |v| v + 1 }
    elsif /my[ _]hero[ _]academia|boku[ _]no[ _]hero[ _]academia/i.match?(episode_name)
      num.map { |v| v - 13 }
    else
      num
    end.select { |v| v > 0 }
  end

  def self.parse_episodes_num episode_name
    fixed_name = episode_name.tr ' ', '_'

    Array(EPISODE_FOR_HISTORY_REGEXES).each do |regex|
      return [Regexp.last_match(1).to_i] if fixed_name.match(regex)
    end
    EPISODES_FOR_HISTORY_REGEXES.each do |regex|
      if fixed_name.match(regex)
        return ((Regexp.last_match(1).to_i)..(Regexp.last_match(2).to_i)).to_a
      end
    end
    EPISODES_WITH_COMMA_FOR_HISTORY_REGEXES.each do |regex|
      if fixed_name.match(regex)
        return (
          (Regexp.last_match(1).to_i)..(Regexp.last_match(2).to_i)
        ).to_a << Regexp.last_match(3).to_i
      end
    end
    []
  end

  def self.grab_ongoings _test = false, anime_id = nil
    parse_feed get_rss, anime_id
  end

  def self.grab_page url, anime_id = nil
    parse_feed get_page(url), anime_id
  end

  def self.get_rss
    content = get(rss_url)

    doc = Nokogiri::XML(content)
    feed = doc.xpath('//channel//item').map do |v|
      category = v.xpath('category')[0]
      if category &&
          category.inner_html =~ /^(?:English-scanlated Books|Raw Books)$/
        next
      end
      {
        title: v.xpath('title')[0].inner_html,
        link: v.xpath('link')[0].inner_html.gsub('&amp;', '&'),
        guid: v.xpath('guid')[0].inner_html.gsub('&amp;', '&'),
        pubDate: Time.zone.parse(v.xpath('pubDate')[0].inner_html)
      }
    end.compact

    filter_bad_formats(feed)
  end

  def self.parse_feed feed, anime_id
    print format("fetched %<size>d torrens\n", size: feed.size)
    return 0 if feed.empty?

    animes = !anime_id.nil? ? [Anime.find(anime_id)] : get_ongoings
    errors = []

    result = animes.sum do |anime|
      matches = feed.select do |v|
        unless ANIME_WITH_ALL_SUB_GROUPS.include?(anime.id) # некоторые аниме только эти негодяи сабят
          next if v[:title].include? '[KRT]' # эти негодяи совсем криво торренты именуют
          next if v[:title].include? '[Arabic]' # это вообще какие-то неадекваты
        end

        TorrentsMatcher.new(anime).matches_for(
          v[:title],
          only_name: ANIME_WITH_NAME_MATCH_ONLY.include?(anime.id),
          exact_name: anime.options.include?(Types::Anime::Options[:strict_torrent_name_match])
        )
      end

      matches.any? ? add_episodes(anime, matches) : 0
    rescue ActiveRecord::RecordNotSaved => e
      errors << e.message
      0
    end

    if errors.none?
      result
    else
      raise ::MissingEpisodeError.new(anime_id, errors)
    end
  end

  def self.get_ongoings
    ongoings = Anime.where(status: :ongoing).to_a

    anons = Anime
      .where(status: :anons)
      .where(kind: %i[tv ona])
      .where(episodes_aired: 0)
      .includes(:anime_calendars)
      .references(:anime_calendars)
      .where('anime_calendars.episode = 1 and anime_calendars.start_at < now()')
      .to_a

    anons.delete_if { |v| v.kind_ona? && v.anime_calendars.empty? }

    released = Anime
      .where('released_on_computed >= ?', 2.weeks.ago)
      .where('episodes_aired >= 5')
      .to_a

    (ongoings + anons + released).select do |anime|
      !anime.kind_special? &&
        anime.options.exclude?(Types::Anime::Options[:disabled_torrents_sync])
        # && !Anime::EXCLUDED_ONGOINGS.include?(v.id)
    end
  end

  def self.add_episodes anime, feed
    new_episodes = check_aired_episodes anime, feed

    torrents_before = Animes::Torrents::Get.call(anime)

    if new_episodes.empty?
      new_torrents = feed.select do |v|
        v[:title].match(/x720|x768|720p|x400|400p|x480|480p|x1080|1080p/)
      end

      unless new_torrents.empty?
        torrents_after = (
          (torrents_before.is_a?(String) ? [] : torrents_before) + new_torrents
        )
          .select { |v| v.is_a?(Hash) && v[:title] }
          .uniq { |v| v[:title] }

        if torrents_before.size != torrents_after.size
          print format(
            "%<size>d new torrent(s) found for %<name>s\n",
            size: torrents_after.size - torrents_before.size,
            name: anime.name
          )
          Animes::Torrents::Set.call(anime, torrents_after)
        end
      end
      0
    else
      print format(
        "%<size>d new episodes(s) found for %<name>s\n",
        size: new_episodes.size,
        name: anime.name
      )
      Animes::Torrents::Set.call(
        anime,
        (torrents_before + new_episodes).uniq { |v| v[:title] }
      )

      new_episodes.size
    end
  end

  def self.filter_bad_formats(feed)
    feed.select { |v| v[:title].match(/(?:avi|mkv|mp4|\]|[^\.]{5})$/) }
  end

  # добавление новых эпизодов из rss фида
  def self.check_aired_episodes anime, feed
    episode_min = anime.changes['episodes_aired'] || anime.episodes_aired || 0
    episode_max = anime.episodes_aired || 0

    new_episodes = []

    feed
      .each { |v| v[:episodes] = TorrentsParser.extract_episodes_num v[:title] }
      .select { |v| v[:episodes].any? }
      .sort_by { |v| v[:episodes].min }
      .each do |entry|
        next if entry[:episodes].none?

        # для онгоингов и анонсов при нахождении более одного эпизода, игнорируем подобные находки
        episodes_diff = [
          entry[:episodes].min - anime.episodes_aired,
          entry[:episodes].max - anime.episodes_aired
        ].max
        next if entry[:episodes].none?
        next if (anime.ongoing? || anime.anons?) &&
          episodes_diff > entry[:episodes].size &&
          !(entry[:episodes].max > 1 && anime.episodes_aired.zero?)
        next if episodes_diff >= 10

        entry[:episodes].each do |episode|
          if (anime.episodes.positive? && episode > anime.episodes) ||
              episode_min >= episode
            next
          end
          episode_max = episode if episode_max < episode
          new_episodes << entry

          aired_at = (entry[:pubDate] || Time.zone.now) + episode.seconds
          # Shikimori::DOMAIN_LOCALES.each do |locale|
          #   Topics::Generate::News::EpisodeTopic.call(
          #     model: anime,
          #     user: anime.topic_user,
          #     locale: locale,
          #     aired_at: aired_at,
          #     episode: episode
          #   )
          # end

          EpisodeNotification::Track.call(
            anime: anime,
            episode: episode,
            aired_at: aired_at,
            is_raw: true
          )

          # episodes_aired must be set becase
          # anime object is used in next iterations
          anime.episodes_aired = episode
        end
      end

    # anime.episodes_aired = episode_max
    # anime.save if anime.changed?

    new_episodes.uniq
  end

  private_class_method

  def self.get url
    Proxy.get(
      url,
      timeout: 30,
      log: PROXY_LOG,
      no_proxy: true
    )
  end

  def self.ignored_phrases? title
    IGNORED_PHRASES.any? do |phrases|
      phrases.all? { |phrase| title.include? phrase }
    end
  end
end
