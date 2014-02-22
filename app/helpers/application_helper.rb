require 'digest/md5'

module ApplicationHelper
  def title(page_title)
    content_for(:title, page_title)
  end

  def attachment_url(file, style = :original, with_timestamp = true)
    "#{request.protocol}#{request.host_with_port}#{file.url style, with_timestamp}"
  end

  def rus_date(date, fix_1_1=false)
    if fix_1_1 && date.day == 1 && date.month == 1
      "#{date.year} г."
    else
      Russian::strftime(date, '%d %B %Y г.').sub(/^0/, '') if date
    end
  end

  # форматирование html текста для вывода в шаблон
  def format_html_text(text)
    text.gsub(/\[spoiler\](?:<br ?\/?>|\n)?(.*?)(?:<br ?\/?>|\n)?\[\/spoiler\](?:<br ?\/?>|\n)?/mi,
              '<div class="collapse"><span class="action half-hidden" style="display: none;">развернуть</span></div><div class="collapsed spoiler" style="display: block;">спойлер</div><div class="target" style="display: none;">\1<span class="closing"></span></div>')
  end

  # удаление спойлеров и дополнений в скобочках в из текста
  def remove_misc_data(text)
    text
      .gsub(/\[spoiler\][\s\S]*?\[\/spoiler\]|\]\]|\[\[|\([\s\S]*?\)|\[[\s\S]*?\]/, '')
      .gsub(/<(?!br).*?>/, '')
      .gsub(/<br *\/?>/, '')
  end

  def sitelink(url)
    Rails.logger.warn 'sitelink call is deprecated'
    link_to url.gsub(/^http:\/\/|www\.|\/$/, ''), url, :rel => :nofollow
  end

  def connected_providers_for(user)
    user.user_tokens.collect{|v| v.provider.to_sym }
  end

  def unconnected_providers_for(user)
    User.omniauth_providers.select {|v| v != :google_apps && v != :yandex } - user.user_tokens.collect {|v| v.provider.to_sym }
  end

  def format_rss_urls(text)
    text.gsub('href="/', 'href="http://shikimori.org/').gsub('src="/', 'src="http://shikimori.org/')
  end

  # активны ли рекомендации манги
  def manga_recommendations?
    cookies[RecommendationsController::CookieName] == Manga.name.downcase
  end

  def time_ago_in_words(date, format_string=nil, original=false)
    if original || date + 1.day > DateTime.now
      format_string ? format_string % super(date) : super(date)
    else
      Russian::strftime(date, "%e %B %Y")
    end
  end

  # костыли для совместимости старого Devise с Rails 3.2
  def password_path(resource_name)
    user_password_path
  end

  def new_session_path(resource_name)
    new_user_session_path
  end
end
