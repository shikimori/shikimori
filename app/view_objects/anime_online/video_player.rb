class AnimeOnline::VideoPlayer
  include Draper::ViewHelpers
  prepend ActiveCacher.instance

  vattr_initialize :anime
  instance_cache :nav, :current_episode, :current_video, :videos,
    :anime_video_episodes, :episode_topic_view, :same_videos,
    :cache_key, :episode_videos_cache_key, :episode_cache_key, :all_kind?

  PREFERENCES_KIND = 'anime_video_kind'
  PREFERENCES_LANGUAGE = 'anime_video_language'
  PREFERENCES_HOSTING = 'anime_video_hosting'
  PREFERENCES_AUTHOR = 'anime_video_author'

  CACHE_VERSION = :v4

  def nav
    AnimeOnline::VideoPlayerNavigation.new self
  end

  def current_video
    video =
      if video_id > 0
        videos.find { |v| v.id == video_id }
      else
        try_select_by(
          h.cookies[PREFERENCES_KIND],
          h.cookies[PREFERENCES_LANGUAGE],
          h.cookies[PREFERENCES_HOSTING],
          h.cookies[PREFERENCES_AUTHOR]
        )
      end

    if !video && h.params[:video_id]
      video = AnimeVideo.find_by(id: h.params[:video_id])
    end

    video&.decorate
  end

  def videos
    videos = @anime.anime_videos
      .includes(:author)
      .where(episode: current_episode)

    AnimeOnline::FilterSovetRomantica.call(videos)
      .map(&:decorate)
      .sort_by(&:sort_criteria)
  end

  def videos_by_kind
    return {} if videos.blank?

    videos
      .select(&:allowed?)
      .uniq(&:uniq_criteria)
      .sort_by(&:sort_criteria)
      .group_by(&:kind_text)
  end

  def all_kind?
    (
      h.current_user&.trusted_video_uploader? || h.can?(:edit, current_video)
    ) && (
      videos_by_kind.many? ||
      videos.group_by(&:kind_text).many? ||
      videos.any? { |anime_video| !anime_video.allowed? }
    )
  end

  def anime_video_episodes
    AnimeOnline::AnimeVideoEpisodes.call(@anime)
  end

  def current_episode
    if h.params[:episode]
      ApplicationRecord.fix_id(
        h.params[:episode].to_i
      ) || 1
    else
      1
    end
  end

  def episode_url episode = current_episode
    h.play_video_online_index_url @anime, episode
  end

  def prev_url
    episode = episodes.reverse.find { |v| v < current_episode }
    episode ||= episodes.last
    episode_url episode if episode
  end

  def next_url
    episode = episodes.find { |v| v > current_episode }
    episode ||= episodes.first
    episode_url episode if episode
  end

  def next_watch_url
    episode = episodes.find { |v| v > current_episode }

    if episode
      episode_url episode
    else
      @anime.url false
    end
  end

  def report_url kind
    h.moderation_anime_video_reports_url(
      'anime_videos_report[kind]' => kind,
      'anime_videos_report[anime_video_id]' => current_video.id,
      'anime_videos_report[user_id]' => h.current_user.try(:id) || User::GUEST_ID,
      'anime_videos_report[message]' => ''
    )
  end

  def episode_title
    if current_episode.zero?
      'Прочее'
    else
      "Эпизод #{current_episode}"
    end
  end

  def same_videos
    return [] unless current_video

    filtered_videos = videos
      .group_by(&:uniq_criteria)[current_video.uniq_criteria] || []

    if current_video.allowed?
      filtered_videos.select(&:allowed?)
    else
      filtered_videos
    end
  end

  # список типов коллекции видео
  def kinds videos
    videos
      .map(&:kind)
      .uniq
      .map { |v| I18n.t "enumerize.anime_video.kind.#{v}" }
      .uniq
      .join(', ')
  end

  # список хостингов коллекции видео
  def hostings videos
    videos
      .map(&:hosting)
      .uniq
      .sort_by { |v| AnimeVideoDecorator::HOSTINGS_ORDER[v] || v }
      .join(', ')
  end

  def new_report
    AnimeVideoReport.new(
      anime_video_id: current_video.id,
      user_id: h.current_user.try(:id) || User::GUEST_ID,
      state: 'pending',
      kind: 'broken'
    )
  end

  def new_video_url
    h.new_video_online_url(
      'anime_video[anime_id]' => @anime.id,
      'anime_video[source]' => Shikimori::DOMAIN,
      'anime_video[state]' => 'uploaded',
      'anime_video[kind]' => 'fandub',
      'anime_video[language]' => 'russian',
      'anime_video[quality]' => 'tv',
      'anime_video[episode]' => current_episode
    )
  end

  def remember_video_preferences
    if current_video&.persisted? && current_video&.valid?
      h.cookies[PREFERENCES_KIND] = current_video.kind
      h.cookies[PREFERENCES_LANGUAGE] = current_video.language
      h.cookies[PREFERENCES_HOSTING] = current_video.hosting
      h.cookies[PREFERENCES_AUTHOR] =
        cleanup_author_name(current_video.author_name)
    end
  end

  # def compatible? video
    # !(h.mobile?) ||
      # !!(h.request.user_agent =~ /android/i) ||
      # video.vk? || video.smotret_anime?
  # end

  def episode_topic_view
    topic = @anime.object.news_topics.find_by(
      action: :episode,
      value: current_episode,
      locale: :ru
    )

    Topics::TopicViewFactory.new(true, false).build topic if topic
  end

  def cache_key
    [
      @anime.id,
      # т.к. id может попасть в copyrighted_ids, что поломает ссылки
      @anime.to_param,
      @anime.anime_videos.cache_key,
      CACHE_VERSION
    ]
  end

  def videos_cache_key
    cache_key + [current_episode, :videos, all_kind?]
  end

  def episode_videos_cache_key
    [
      @anime.id,
      # т.к. id может попасть в copyrighted_ids, что поломает ссылки
      @anime.to_param,
      @anime.anime_videos.where(episode: current_episode).cache_key,
      :episode_videos,
      current_episode,
      CACHE_VERSION,
      all_kind?
    ]
  end

private

  def episodes
    anime_video_episodes.map(&:episode)
  end

  def try_select_by kind, language, hosting, fixed_author_name
    by_kind = videos.select(&:allowed?).select { |v| v.kind == kind }
    by_language = by_kind.select { |v| v.language == language }
    by_hosting = by_language.select { |v| v.hosting == hosting }
    by_author = by_hosting.select do |anime_video|
      cleanup_author_name(anime_video.author_name) == fixed_author_name
    end

    by_author.first || by_hosting.first || by_language.first || by_kind.first ||
      videos.select(&:allowed?).first || videos.first
  end

  def video_id
    h.params[:video_id].to_i
  end

  def cleanup_author_name name
    (name || '').sub(/(?<!^)\(.*\)/, '').strip
  end
end
