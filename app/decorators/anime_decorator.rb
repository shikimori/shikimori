class AnimeDecorator < AniMangaDecorator
  instance_cache :files, :coubs, :next_episode_at

  def news_topic_views
    return [] if rkn_abused?

    object
      .news_topics
      .where(locale: h.locale_from_host)
      .includes(:forum)
      .limit(NEWS_PER_PAGE)
      .order(:created_at)
      .map { |topic| Topics::TopicViewFactory.new(false, false).build topic }
      .map { |topic_view| format_menu_topic topic_view, :created_at }
  end

  def screenshots limit = nil
    return [] unless screenshots_allowed?

    @screenshots ||= {}
    @screenshots[limit] ||=
      if object.respond_to? :screenshots
        object.screenshots.limit limit
      else
        []
      end
  end

  def screenshots_allowed?
    Copyright::ANIME_SCREENSHOTS.exclude?(id) && !censored? && !rkn_abused?
  end

  def videos limit = nil # rubocop:disable PerceivedComplexity, CyclomaticComplexity, AbcSize
    return [] if Copyright::ANIME_VIDEOS.include?(id) && !rkn_abused?
    return [] unless object.respond_to? :videos

    # return [] unless h.ignore_copyright?
    # return [] if forbidden?

    @videos ||= {}
    @videos[limit] ||= (limit ? object.videos.ordered.limit(limit) : object.videos)
      .sort_by do |video|
        if video.op? || video.ed?
          match = video.name&.match(/\b(?:op|ed|opening|ending)[0 ]*(\d+)/i)
        end

        [
          Types::Video::KINDS.index(video.kind.to_sym),
          match ? match[1].to_i : -1,
          video.id
        ]
      end
  end

  def files
    AniMangaDecorator::Files.new object
  end

  def coubs
    Coubs::Fetch.call(tags: coub_tags, iterator: nil)
  end

  def next_episode_at with_broadcast = true # rubocop:disable CyclomaticComplexity
    return unless ongoing? || anons?

    calendars_for_next_episode
      .find { |v| v.episode > episodes_aired }
      &.start_at ||
        object.next_episode_at ||
        (next_broadcast_at if with_broadcast)
  end

  # try to take the date from animecalendar if possible
  def aired_on
    return super unless anons?

    (next_episode_at(false) if super && super < Time.zone.now) || super
  end

  # for schema.org
  def itemtype
    'http://schema.org/Movie'
  end

  def fansubbers
    rkn_abused? ? [] : super
  end

  def fandubbers
    rkn_abused? ? [] : super
  end

  def sorted_fansubbers
    @sorted_fansubbers ||= fansubbers
      .map { |name| fix_group_name name }
      .sort_by { |name| group_name_sort_criteria name }
  end

  def sorted_fandubbers
    @sorted_fandubbers ||= fandubbers
      .map { |name| fix_group_name name }
      .sort_by { |name| group_name_sort_criteria name }
  end

  def calendars_for_next_episode
    @calendars_for_next_episode ||= association_cached?(:anime_calendars) ?
      anime_calendars
        .select { |v| v.episode == episodes_aired + 1 || v.episode == episodes_aired + 2 } :
      anime_calendars.where(episode: [episodes_aired + 1, episodes_aired + 2]).to_a
  end

  def censored_in_russia?
    Copyright::CENSORED_IN_RUSSIA_ANIME_IDS.include? object.id
  end

private

  def next_broadcast_at
    return if anons? || date_uncertain?(aired_on)
    return unless broadcast_at && broadcast_at > 1.week.ago

    broadcast_at < 1.hour.ago ? broadcast_at + 1.week : broadcast_at
  end

  def fix_group_name name
    name.gsub(/\.(?:tv|ru|com|net|online|su)/i, '')
  end

  def group_name_sort_criteria name
    name.downcase.gsub(/[^a-zа-я]/i, '')
  end
end
