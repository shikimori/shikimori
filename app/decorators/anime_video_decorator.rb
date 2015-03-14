class AnimeVideoDecorator < BaseDecorator
  def views_count
    if watch_view_count && watch_view_count > 0
      "#{watch_view_count} #{Russian.p watch_view_count, 'просмотр', 'просмотра', 'просмотров'}"
    end
  end

  def player_url
    if vk? && reports.any? {|r| r.broken? }
      "#{url}#{url.include?('?') ? '&' : '?' }quality=360"
    else
      url
    end
  end

  def in_list?
    user_rate.present?
  end

  def watched?
    user_rate.episodes >= episode if in_list?
  end

  def user_rate
    @user_rate ||= if h.user_signed_in?
      h.current_user.anime_rates.where(target_id: anime_id, target_type: Anime.name).first
    end
  end

  def add_to_list_url
    h.api_user_rates_path(
      'user_rate[episodes]' => 0,
      'user_rate[score]' => 0,
      'user_rate[status]' => UserRate.statuses[:planned],
      'user_rate[target_id]' => anime.id,
      'user_rate[target_type]' => anime.class.name,
      'user_rate[user_id]' => h.current_user.id
    )
  end

  def viewed_url
    h.viewed_video_online_url(anime, id)
  end

  # сортировка [[озвучка,сабы], [vk.com, остальное], переводчик]
  def sort_criteria
    [
      kind.fandub? || kind.unknown? ? '' : kind,
      vk? ? '' : hosting,
      author ? author.name : ''
    ]
  end

  #delegate_all

  #def description
    #return if object[:description].blank?
    #if object.description_html.blank?
      #h.format_html_text object.description_mal
    #else
      #object.description_html
    #end
  #end

  #def watch_increment_delay
    #duration * 60000 / 3 if duration > 0
  #end

  #def kinds
    #@kinds ||= current_videos.map(&:kind).uniq
  #end


  #def last_date
    #@last_date ||= anime_videos.select{|v| v.allowed?}.map(&:created_at).max || created_at
  #end
end
