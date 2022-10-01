require 'digest/md5'

module ApplicationHelper
  def cache name = {}, *args
    super cache_keys(*Array(name)), *args
  end

  def cache_keys *args
    CacheHelperInstance.cache_keys(*args)
  end

  def itemprop
    if controller.instance_variable_get :@itemtype
      {
        itemscope: '',
        itemtype: controller.instance_variable_get(:@itemtype).html_safe
      }
    else
      {}
    end
  end

  def block &block
    capture(&block)
  end

  def show_social?
    false
  end

  def cdn_image entry, image_size
    ImageUrlGenerator.instance.url entry, image_size
  end

  def meta_image_url file, style = :original, with_timestamp = true
    "#{request.protocol}#{request.host_with_port}#{file.url style, with_timestamp}"
  end

  # TODO: remove
  def formatted_date date, fix_1_day = false, short_month = true, fix_1_month = true
    return unless date

    if fix_1_day
      if fix_1_month && date.day == 1 && date.month == 1
        date.year.to_s
      elsif fix_1_day && date.day == 1
        I18n.l date, format: :month_year_human
      else
        I18n.l(date, format: short_month ? :human_short : :human).strip
      end
    else
      I18n.l(date, format: :human).strip
    end
  end

  def info_line title = nil, value = nil, &block
    value = capture(&block) if value.nil? && block_given?

    if value.present?
      <<~HTML.squish.html_safe
        <div class='line-container'>
         <div class='line'>
           #{"<div class='key'>#{title}:</div>" if title}
           #{"<div class='value'>#{value}</div>" if value}
          </div>
        </div>
      HTML
    end
  end

  def format_percent value
    value.to_s.gsub(/\.0+$/, '') + '%'
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

  def format_rss_urls text
    text
      .gsub(%r{href="/(?!/)}, "href=\"https://#{Shikimori::DOMAIN}/")
      .gsub(%r{src="/(?!/)}, "src=\"https://#{Shikimori::DOMAIN}/")
  end

  def time_ago_in_words date, format_string=nil, original=false
    if original || date > 1.day.ago
      format_string ? format_string % super(date) : super(date)
    else
      I18n.l date, format: '%e %b %Y'
    end
  end

  # костыли для совместимости старого Devise с Rails 3.2
  def password_path _resource_name
    user_password_path
  end

  def new_session_path _resource_name
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
