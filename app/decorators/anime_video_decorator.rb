class AnimeVideoDecorator < Draper::Decorator
  delegate_all

  def name
    if russian
      "#{object.russian} / #{object.name}"
    else
      object.name
    end
  end

  def description
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
    #anime_videos.sort_by {|v| v.episode }
    @video ||= anime_videos.group_by {|v| v.episode}
  end

  def current_videos
    videos[current_episode]
  end

  def comments
    @comments ||= [1,2,3]
  end
end
