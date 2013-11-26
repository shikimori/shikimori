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
    @current_episode ||= [h.params[:episode_id].to_i, 1].max
  end

  def videos
    @video ||= anime_videos.group_by {|v| v.episode}
  end

  def current_videos kind = nil
    videos[current_episode]
  end

  def current_kinds
    current_videos.collect {|v| v.kind }
  end
end
