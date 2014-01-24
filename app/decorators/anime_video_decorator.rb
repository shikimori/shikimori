class AnimeVideoDecorator < AnimeVideoPreviewDecorator
  delegate_all

  def description
    return if object[:description].blank?
    if object.description_html.blank?
      h.format_html_text object.description_mal
    else
      object.description_html
    end
  end

  def current_episode
    @current_episode ||= if h.params[:episode]
      h.params[:episode].to_i
    else
      videos.first.try(:first).to_i
    end
  end

  def videos
    @videos ||= anime_videos
      .select {|v| all? || v.allowed?}
      .sort_by {|v| [v.episode.zero? ? 1 : 0, v.episode] }
      .group_by(&:episode)
  end

  def current_videos
    @current_videos ||= videos[current_episode]
  end

  # сортировка [[озвучка,сабы], [vk.com, остальное], переводчик]
  def dropdown_videos
    return [] if current_videos.blank?
    current_videos.sort_by do |v|
      [v.kind.fandub? || v.kind.unknown? ? '' : v.kind, v.hosting == 'vk.com' ? '' : v.hosting, v.author ? v.author.name : '']
    end
  end

  def current_video
    @current_video ||= unless current_videos.blank?
      if video_id > 0
        current_videos.select {|v| v.id == video_id}.first
      else
        try_select_by h.cookies[:preference_kind], h.cookies[:preference_hosting], h.cookies[:preference_author_id].to_i
      end
    end
  end

  def try_select_by kind, hosting, author_id
    by_kind = current_videos.select {|v| v.kind == kind}
    if by_kind.blank?
      current_videos.first
    else
      by_hosting = by_kind.select {|v| v.hosting == hosting}
      if by_hosting.blank?
        by_kind.first
      else
        by_author = by_hosting.select {|v| v.anime_video_author_id == author_id}
        if by_author.blank?
          by_hosting.first
        else
          by_author.first
        end
      end
    end
  end

  # TODO move in VideoDecorator
  def current_author
    h.truncate h.strip_tags(current_video.author.name), :length => 20, :omission => '...' if current_video && current_video.author
  end

  def current_episode_title
    if current_episode.zero?
      "Прочее"
    else
      "Эпизод #{current_episode}"
    end
  end

  def kinds
    @kinds ||= current_videos.map(&:kind).uniq
  end

  def dropdown_kinds videos
    videos.map(&:kind).uniq.collect {|v| I18n.t("enumerize.anime_video.kind.#{v}")}.uniq.join ', '
  end

  def hostings videos
    videos.map(&:hosting).uniq.sort_by{|h| h == 'vk.com' ? '' : h}.join ', '
  end

  def current_first?
    current_episode == 1
  end

  def current_last?
    current_episode == videos.keys.last
  end

  def url episode = current_episode
    h.anime_videos_show_url(id, episode)
  end

  def prev_url
    url videos.keys[videos.keys.index(current_episode)-1]
  end

  def next_url
    url videos.keys[videos.keys.index(current_episode)+1]
  end

  def video_id
    h.params[:video_id].to_i
  end

  def all?
    h.params[:all] && h.current_user.try(:video_moderator?)
  end

  def last_episode
    @last_episode ||= videos.max().first unless videos.blank?
  end
end
