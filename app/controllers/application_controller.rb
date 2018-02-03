class ApplicationController < ActionController::Base
  include Translation
  include ErrorsConcern
  include UrlsConcern
  include OpenGraphConcern
  include BreadcrumbsConcern
  include InvalidParameterErrorConcern

  #include Mobylette::RespondToMobileRequests
  protect_from_forgery with: :exception

  layout :set_layout

  before_action :set_locale
  before_action :set_user_locale_from_host
  before_action :set_layout_view
  before_action :fix_googlebot
  before_action :touch_last_online
  before_action :mailer_set_url_options
  before_action :force_vary_accept

  helper_method :resource_class
  helper_method :remote_addr
  helper_method :json?
  helper_method :adaptivity_class
  helper_method :turbolinks_request?
  helper_method :base_controller_names
  helper_method :ignore_copyright?

  helper_method :shikimori?, :anime_online?, :manga_online?
  helper_method :ru_host?, :locale_from_host
  helper_method :i18n_i, :i18n_io, :i18n_v

  I18n.exception_handler = -> (exception, locale, key, options) {
    # raise I18n::MissingTranslation, "#{locale} #{key}"
    raise I18n::NoTranslation, "#{locale} #{key}"
  }

  def self.default_url_options
    { protocol: Shikimori::PROTOCOL }
  end

  def default_url_options options = {}
    if params[:locale]
      options.merge protocol: Shikimori::PROTOCOL, locale: params[:locale]
    else
      options.merge protocol: Shikimori::PROTOCOL
    end
  end

  def turbolinks_request?
    request.headers['X-XHR-Referer'].present?
  end

  def current_user
    @decorated_current_user ||= super.try :decorate
  end

  #-----------------------------------------------------------------------------
  # domain helpers
  #-----------------------------------------------------------------------------

  def shikimori?
    ShikimoriDomain::HOSTS.include?(request.host)
  end

  def anime_online?
    AnimeOnlineDomain::HOSTS.include?(request.host)
  end

  def manga_online?
    MangaOnlineDomain::HOSTS.include?(request.host)
  end

  #-----------------------------------------------------------------------------
  # host helpers
  #-----------------------------------------------------------------------------

  def ru_host?
    return true if Rails.env.test?
    return true if anime_online?
    return true if manga_online?

    ShikimoriDomain::RU_HOSTS.include?(request.host)
  end

  def locale_from_host
    ru_host? ? Types::Locale[:ru] : Types::Locale[:en]
  end

  private

  def set_layout
    if request.xhr? || (
        request.headers['HTTP_REFERER'] &&
        URI.parse(request.headers['HTTP_REFERER']).host != URI.parse(request.url).host &&
        request.headers['rack.cors'] && request.headers['rack.cors'].hit
      )
      'xhr'
    else
      Rails.env.development? && params[:no_layout] ? 'xhr' : 'application'
    end
  rescue URI::InvalidURIError
    'application'
  end

  def set_locale
    I18n.locale = params[:locale] || current_user&.locale || locale_from_host
  end

  def set_user_locale_from_host
    return unless user_signed_in?
    return if current_user.locale_from_host == locale_from_host.to_s

    current_user.update_column :locale_from_host, locale_from_host
  end

  def set_layout_view
    @layout = LayoutView.new
  end

  # before фильтры с настройкой сайта
  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  # гугловский бот со странным format иногда ходит
  def fix_googlebot
    if request.format.to_s =~ %r%\*\/\*%
      request.format = :html
    end
  end

  # хром некорректно обрабатывает Back кнопку,
  # если на аякс ответ не послан заголовок Vary: Accept
  def force_vary_accept
    if json?
      response.headers['Vary'] = 'Accept'
      response.headers['Pragma'] = 'no-cache' if request.env['HTTP_USER_AGENT'] =~ /Firefox/
    end
  end

  # трогаем lastonline у текущего пользователя
  def touch_last_online
    return unless user_signed_in? && current_user.class != Symbol
    current_user.update_last_online unless current_user.admin?
  end

  def remote_addr
    request.headers['HTTP_X_FORWARDED_FOR'] ||
      request.headers['HTTP_X_REAL_IP'] ||
      request.headers['REMOTE_ADDR']
  end

  def local_addr?
    remote_addr == '127.0.0.1' || remote_addr == '::1'
  end

  def json?
    request.format == Mime::Type.lookup_by_extension('json') ||
      params[:format] == 'json'
  end

  def ignore_copyright?
    ru_host? && (
      current_user&.day_registered? ||
      GeoipAccess.instance.anime_online_allowed?(remote_addr)
    )
  end

  def faye_token
    request.headers['X-Faye-Token'] || params[:faye]
  end
end
