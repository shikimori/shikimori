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

  def cdn_image_url entry, image_size
    ImageUrlGenerator.instance.cdn_image_url entry, image_size
  end

  def cdn_poster_url db_entry:, poster:, derivative:
    ImageUrlGenerator.instance.cdn_poster_url(
      db_entry: db_entry,
      poster: poster,
      derivative: derivative
    )
  end

  def meta_image_url file, style = :original, with_timestamp = true
    "#{request.protocol}#{request.host_with_port}#{file.url style, with_timestamp}"
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

  def format_rss_urls text
    text
      .gsub(%r{href="/(?!/)}, "href=\"https://#{Shikimori::DOMAIN}/")
      .gsub(%r{src="/(?!/)}, "src=\"https://#{Shikimori::DOMAIN}/")
  end

  def time_ago_in_words date, format_string = nil, original = false
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
