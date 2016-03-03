class AnimeOnline::VideoPlayer
  include Draper::ViewHelpers
  prepend ActiveCacher.instance

  vattr_initialize :anime
  instance_cache :nav, :videos, :current_video, :current_videos,
    :last_episode, :episode_videos, :episode_thread

  PREFERENCES_KIND = 'anime_video_kind'
  PREFERENCES_HOSTING = 'anime_video_hosting'
  PREFERENCES_AUTHOR = 'anime_video_author'

  def nav
    AnimeOnline::VideoPlayerNavigation.new self
  end

  def current_videos
    videos[current_episode]&.map(&:decorate)&.sort_by(&:sort_criteria)
  end

  def first_episode?
    current_episode == 1
  end

  def last_episode?
    current_episode == videos.keys.last
  end

  def current_episode
    if h.params[:episode]
      h.params[:episode].to_i
    else
      videos.first&.try(:first).to_i
    end
  end

  def current_video
    video = if current_videos.present?
      if video_id > 0
        current_videos.find { |v| v.id == video_id }
      else
        try_select_by(
          h.cookies[PREFERENCES_KIND],
          h.cookies[PREFERENCES_HOSTING],
          h.cookies[PREFERENCES_AUTHOR]
        )
      end
    end

    video = AnimeVideo.find_by(id: h.params[:video_id]) if !video && h.params[:video_id]

    video.decorate if video
  end

  def episode_url episode = self.current_episode
    h.play_video_online_index_url anime, episode, h.params[:all]
  end

  def prev_url
    return if videos.none?

    if videos.keys.index(current_episode)
      episode_url videos.keys[videos.keys.index(current_episode)-1]
    else
      episode_url videos.keys.sort.last
    end
  end

  def next_url
    return if videos.none?

    if videos.keys.index(current_episode)
      episode_url videos.keys[videos.keys.index(current_episode)+1]
    else
      episode_url videos.keys.first
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
      "Прочее"
    else
      "Эпизод #{current_episode}"
    end
  end

  def episode_videos
    return [] if current_videos.blank?
    current_videos.uniq(&:uniq_criteria)
  end

  def same_videos
    return [] unless current_videos && current_video
    current_videos.group_by(&:uniq_criteria)[current_video.uniq_criteria] || []
  end

  # список типов коллекции видео
  def kinds videos
    videos
      .map(&:kind)
      .uniq
      .map {|v| I18n.t "enumerize.anime_video.kind.#{v}" }
      .uniq
      .join(', ')
  end

  # список хостингов коллекции видео
  def hostings videos
    videos
      .map(&:hosting)
      .uniq
      .sort_by {|h| h == 'vk.com' ? '' : h }
      .join(', ')
  end

  def last_episode
    videos.max().first unless videos.blank?
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
      'anime_video[anime_id]' => anime.id,
      'anime_video[source]' => Site::DOMAIN,
      'anime_video[state]' => 'uploaded',
      'anime_video[kind]' => 'fandub',
      'anime_video[language]' => 'russian',
      'anime_video[quality]' => 'tv',
      'anime_video[episode]' => current_episode
    )
  end

  def remember_video_preferences
    if current_video && current_video.persisted? && current_video.valid?
      h.cookies[PREFERENCES_KIND] = current_video.kind
      h.cookies[PREFERENCES_HOSTING] = current_video.hosting
      h.cookies[PREFERENCES_AUTHOR] = cleanup_author_name(current_video.author_name)
    end
  end

  def compatible? video
    return true unless h.mobile?
    video.vk? || !!(h.request.user_agent =~ /Android/)
  end

  def episode_thread
    thread = anime.object.topics.find_by(
      type: Topics::NewsTopic.name,
      action: :episode,
      value: current_episode
    )

    Topics::TopicViewFactory.new(true, false).build thread if thread
  end

private

  def videos
    @anime.anime_videos
      .includes(:author)
      .select { |v| all? || v.allowed? }
      .select { |v| compatible?(v) }
      .sort_by { |v| [v.episode.zero? ? 1 : 0, v.episode, v.id] }
      .group_by(&:episode)
  end

  def try_select_by kind, hosting, fixed_author_name
    by_kind = current_videos.select { |v| v.kind == kind }
    by_hosting = by_kind.select { |v| v.hosting == hosting }
    by_author = by_hosting.select { |v| cleanup_author_name(v.author_name) == fixed_author_name }

    by_author.first || by_hosting.first || by_kind.first || current_videos.first
  end

  def all?
    h.params[:all] && h.current_user.try(:video_moderator?)
  end

  def video_id
    h.params[:video_id].to_i
  end

  def cleanup_author_name name
    (name || '').sub(/(?<!^)\(.*\)/, '').strip
  end
end
