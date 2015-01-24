class AnimeVideoDecorator < BaseDecorator#AnimeVideoPreviewDecorator

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



  #def last_episode
    #@last_episode ||= videos.max().first unless videos.blank?
  #end

  #def last_date
    #@last_date ||= anime_videos.select{|v| v.allowed?}.map(&:created_at).max || created_at
  #end

  #def rate
    #@rate ||= h.user_signed_in? ? object.rates.where(user_id: h.current_user).first : nil
  #end
end
