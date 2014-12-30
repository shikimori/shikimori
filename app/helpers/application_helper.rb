require 'digest/md5'

module ApplicationHelper
  def itemprop
    if @itemtype
      { itemscope: '', itemtype: @itemtype.html_safe }
    else
      {}
    end
  end

  def block &block
    capture(&block)
  end

  def show_social?
    !is_mobile_request? && (!user_signed_in? || current_user.preferences.show_social_buttons?)
    false
  end

  def title page_title
    content_for :title, page_title
  end

  def attachment_url file, style = :original, with_timestamp = true
    "#{request.protocol}#{request.host_with_port}#{file.url style, with_timestamp}"
  end

  def rus_date date, fix_1_1=false
    return unless date

    if fix_1_1
      if date.day == 1 && date.month == 1
        "#{date.year} г."
      elsif fix_1_1 && date.day == 1
        Russian::strftime date, '%B %Y г.'
      else
        Russian::strftime(date, '%e %b %Y г.').strip
      end
    else
      Russian::strftime(date, '%e %B %Y г.').strip
    end
  end

  def info_line title, value=nil, &block
    value = capture(&block) if value.nil? && block_given?
    if value.present?
      "<div class='line'>
        <div class='key'>#{title}:</div>
        <div class='value'>#{value}</div>
      </div>".html_safe
    end
  end

  # форматирование html текста для вывода в шаблон
  # TODO: выпилить
  def format_html_text text
    raise 'deprecated. use decorator instead'
    text
      .gsub(/\[spoiler\](?:<br ?\/?>|\n)?(.*?)(?:<br ?\/?>|\n)?\[\/spoiler\](?:<br ?\/?>|\n)?/mi,
            '<div class="collapse"><span class="action half-hidden" style="display: none;">развернуть</span></div><div class="collapsed spoiler">спойлер</div><div class="target spoiler" style="display: none;">\1<span class="closing"></span></div>')
      .html_safe
  end

  # удаление спойлеров и дополнений в скобочках в из текста
  def remove_misc_data text
    text
      .gsub(/\[spoiler\][\s\S]*?\[\/spoiler\]|\]\]|\[\[|\([\s\S]*?\)|\[[\s\S]*?\]/, '')
      .gsub(/<(?!br).*?>/, '')
      .gsub(/<br *\/?>/, '')
  end

  def sitelink url
    Rails.logger.warn 'sitelink call is deprecated'
    link_to url.gsub(/^http:\/\/|www\.|\/$/, ''), url, :rel => :nofollow
  end

  def format_rss_urls text
    text.gsub('href="/', 'href="http://shikimori.org/').gsub('src="/', 'src="http://shikimori.org/')
  end

  # активны ли рекомендации манги
  def manga_recommendations?
    cookies[RecommendationsController::CookieName] == Manga.name.downcase
  end

  def time_ago_in_words date, format_string=nil, original=false
    if original || date + 1.day > DateTime.now
      format_string ? format_string % super(date) : super(date)
    else
      Russian::strftime(date, "%e %B %Y")
    end
  end

  # костыли для совместимости старого Devise с Rails 3.2
  def password_path resource_name
    user_password_path
  end

  def new_session_path resource_name
    new_user_session_path
  end

  def mobile?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      request.user_agent =~ /Mobile|webOS|Android/
    end
  end
end
