class AnimeVideoDecorator < AnimeVideoPreviewDecorator
  delegate_all

  def description
    object[:description] unless current_episode > 1
  end

  def current_episode
    @current_episode ||= [episode_id, 1].max
  end

  def videos
    @video ||= anime_videos.group_by {|v| v.episode}
  end

  def current_videos
    @current_videos ||= videos[current_episode]
  end

  # сортировка [[озвучка,сабы], [vk.com, остальное], переводчик]
  def dropdown_videos
    current_videos.sort_by {|v| [v.kind.fandub? || v.kind.unknown? ? '' : v.kind, v.hosting == 'vk.com' ? '' : v.hosting, v.author] }
  end

  def current_video
    @current_video ||= unless current_videos.blank?
      if video_id > 0
        current_videos.select {|v| v.id == video_id}.first
      else
        current_videos.first
      end
    end
  end

  def current_author
    h.truncate h.strip_tags(current_video.author.name), :length => 20, :omission => '...'
  end

  def kinds
    @kinds ||= current_videos.map(&:kind).uniq
  end

  #def kinds? value
    #kinds.include? value.to_s
  #end

  #def kind_active? value
    #if current_video.kind.unknown? && value == :fandub
      #true
    #else
      #current_video.kind == value.to_s
    #end
  #end

  def dropdown_kinds
    kinds.collect {|v| I18n.t("enumerize.anime_video.kind.#{v}")}.uniq.join ', '
  end

  def hostings
    @hostings ||= current_videos.map(&:hosting).uniq.join ', '
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
    url current_episode - 1
  end

  def next_url
    url current_episode + 1
  end

  def episode_id
    h.params[:episode_id].to_i
  end

  def video_id
    h.params[:video_id].to_i
  end
end
