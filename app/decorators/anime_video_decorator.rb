class AnimeVideoDecorator < AnimeVideoPreviewDecorator
  delegate_all

  def description
    return if current_episode > 1

    if object.description_html.blank?
      h.format_html_text object.description_mal
    else
      object.description_html
    end
  end

  def current_episode
    @current_episode ||= [episode_id, 1].max
  end

  def videos
    @video ||= anime_videos.group_by {|v| v.episode}
  end

  def current_videos
    videos[current_episode]
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

  def episode_id
    h.params[:episode_id].to_i
  end

  def video_id
    h.params[:video_id].to_i
  end
end
