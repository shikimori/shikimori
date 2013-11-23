class AnimeVideoDecorator < AnimeVideoPreviewDecorator
  delegate_all

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
