class AnimeOnline::VideoPlayer
  include Draper::ViewHelpers
  prepend ActiveCacher.instance

  vattr_initialize :anime
  instance_cache :nav, :videos, :current_video, :last_episode

  def nav
    AnimeOnline::VideoPlayerNavigation.new self
  end

  def current_videos
    videos[current_episode]
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
      videos.first.try(:first).to_i
    end
  end

  def current_video
    unless current_videos.blank?
      video = if video_id > 0
        current_videos.find {|v| v.id == video_id }
      else
        try_select_by h.cookies[:preference_kind], h.cookies[:preference_hosting], h.cookies[:preference_author_id].to_i
      end

      video.decorate if video
    end
  end

  # TODO move to VideoDecorator
  #def current_author
    #h.truncate h.strip_tags(current_video.author.name), :length => 20, :omission => '...' if current_video && current_video.author
  #end

  def episode_url episode = self.current_episode
    h.play_video_online_index_url anime, episode
  end

  def prev_url
    episode_url videos.keys[videos.keys.index(current_episode)-1]
  end

  def next_url
    episode_url videos.keys[videos.keys.index(current_episode)+1]
  end

  def report_url kind
    h.moderation_anime_video_reports_url(
      'anime_videos_report[kind]' => kind,
      'anime_videos_report[anime_video_id]' => current_video.id,
      'anime_videos_report[user_id]' => h.current_user.try(:id) || User::GuestID,
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

  def dropdown_kinds videos
    videos
      .map(&:kind)
      .uniq
      .map {|v| I18n.t "enumerize.anime_video.kind.#{v}" }
      .uniq
      .join(', ')
  end

  # сортировка [[озвучка,сабы], [vk.com, остальное], переводчик]
  def episode_videos
    return [] if current_videos.blank?
    current_videos.sort_by do |v|
      [v.kind.fandub? || v.kind.unknown? ? '' : v.kind, v.vk? ? '' : v.hosting, v.author ? v.author.name : '']
    end
  end

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
      user_id: h.current_user.try(:id) || User::GuestID,
      state: 'pending',
      kind: 'broken'
    )
  end

private
  def videos
    @anime.anime_videos
      .select { |v| all? || v.allowed? }
      .select { |v| h.mobile? ? v.mobile_compatible? : true }
      .sort_by { |v| [v.episode.zero? ? 1 : 0, v.episode] }
      .group_by(&:episode)
  end

  def try_select_by kind, hosting, author_id
    by_kind = current_videos.select {|v| v.kind == kind }
    by_hosting = by_kind.select {|v| v.hosting == hosting }
    by_author = by_hosting.select {|v| v.anime_video_author_id == author_id }

    by_author.first || by_hosting.first || by_kind.first || current_videos.first
  end

  def all?
    h.params[:all] && h.current_user.try(:video_moderator?)
  end

  def video_id
    h.params[:video_id].to_i
  end
end
