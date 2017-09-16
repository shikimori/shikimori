class ApplicationController < ActionController::Base
  include Translation

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
  before_action :force_canonical

  helper_method :url_params
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

  NOT_FOUND_ERRORS = [
    ActionController::RoutingError,
    ActiveRecord::RecordNotFound,
    AbstractController::ActionNotFound,
    ActionController::UnknownFormat,
    NotFoundError
  ]

  RUNTIME_ERRORS = [
    AbstractController::Error,
    ActionController::InvalidAuthenticityToken,
    ActionView::MissingTemplate,
    ActionView::Template::Error,
    Exception,
    PG::Error,
    Encoding::CompatibilityError,
    NoMethodError,
    StandardError,
    SyntaxError,
    CanCan::AccessDenied
  ] + NOT_FOUND_ERRORS

  unless Rails.env.test?
    rescue_from *RUNTIME_ERRORS, with: :runtime_error
  else
    rescue_from StatusCodeError, with: :runtime_error
  end

  I18n.exception_handler = -> (exception, locale, key, options) {
    # raise I18n::MissingTranslation, "#{locale} #{key}"
    raise I18n::NoTranslation, "#{locale} #{key}"
  }

  def self.default_url_options
    { protocol: false }
  end

  def default_url_options options = {}
    protocol = %w(xml rss).include?(params[:format]) ? Site::ALLOWED_PROTOCOL : false

    if params[:locale]
      options.merge protocol: protocol, locale: params[:locale]
    else
      options.merge protocol: protocol
    end
  end

  # хелпер для перевода params к виду, который можно засунуть в url хелперы
  def url_params merged = nil
    new_params = safe_params
      .to_unsafe_h
      .except(:action, :controller)
      .symbolize_keys

    merged ? new_params.merge(merged) : new_params
  end

  # запрос ли это через турболинки
  def turbolinks_request?
    request.headers['X-XHR-Referer'].present?
  end

  def current_user
    @decorated_current_user ||= super.try :decorate
  end

  def base_controller_names
    superclass_name = ('p-' + self.class.superclass.name.to_underscore)
      .sub(/_controller$/, '')
      .sub(/^p-application/, '')
      .sub(/^p-shikimori/, '')
    db_name = 'p-db_entries' if kind_of?(DbEntriesController)

    [superclass_name, db_name].select(&:present?).flat_map {|v| [v, "#{v}-#{params[:action]}" ] }.join(' ')
  end

  # Use this in place of params when generating links to Excel etc.
  # See https://github.com/rails/rails/issues/26289
  def safe_params
    params.except(:host, :port, :protocol).permit!
  end
  helper_method :safe_params

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

  def force_canonical
    @canonical = request.url.sub(/\?[\s\S]*/, '') if request.url.include? '?'
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

  # хром некорректно обрабатывает Back кнопку, если на аякс ответ не послан заголовок Vary: Accept
  def force_vary_accept
    if json?
      response.headers['Vary'] = 'Accept'
      response.headers['Pragma'] = 'no-cache' if request.env['HTTP_USER_AGENT'] =~ /Firefox/
    end
  end

  # трогаем lastonline у текущего пользователя
  def touch_last_online
    return unless user_signed_in? && current_user.class != Symbol
    current_user.update_last_online if current_user.id != 1
  end

  # корректно определяющийся ip адрес пользователя
  def remote_addr
    ip = request.headers['HTTP_X_FORWARDED_FOR'] ||
      request.headers['HTTP_X_REAL_IP'] || request.headers['REMOTE_ADDR']

    return ip if Rails.env.test?

    if [231,296,3801,16029,43714,659,22828,56019,88150,93640,67810,102932,84945].include? current_user&.id
      ip + 'z'
    elsif [70628].include? current_user&.id
      ip + 'x'
    else
      ip
    end
  end

  def local_addr?
    remote_addr == '127.0.0.1' || remote_addr == '::1'
  end

  def json?
    request.format == Mime::Type.lookup_by_extension('json') || params[:format] == 'json'
  end

  def ignore_copyright?
    ru_host? && (
      current_user&.day_registered? ||
      GeoipAccess.instance.allowed?(remote_addr)
    )
  end

  # faye токен текущего пользователя
  def faye_token
    request.headers['X-Faye-Token'] || params[:faye]
  end

  def runtime_error e
    Honeybadger.notify(e) if defined?(Honeybadger)
    Raygun.track_exception(e) if defined?(Raygun)

    NamedLogger.send("#{Rails.env}_errors").error "#{e.message}\n#{e.backtrace.join("\n")}"
    Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"

    raise e if local_addr? && (
      !e.is_a?(AgeRestricted) &&
      !e.is_a?(CopyrightedResource) &&
      !e.is_a?(Forbidden)
    )

    with_json_response = json? ||
      (self.kind_of?(Api::V1Controller) && !params[:frontend])

    if NOT_FOUND_ERRORS.include? e.class
      @sub_layout = nil

      if with_json_response
        render json: { message: t('page_not_found'), code: 404 }, status: 404
      else
        render 'pages/page404', layout: false, status: 404, formats: :html
      end

    elsif e.is_a?(AgeRestricted)
      render 'pages/age_restricted', layout: false, formats: :html

    elsif e.is_a?(Forbidden) || e.is_a?(CanCan::AccessDenied)
      if with_json_response
        render json: { message: e.message, code: 403 }, status: 403
      else
        render plain: e.message, status: 403
      end

    elsif e.is_a?(StatusCodeError)
      render json: {}, status: e.status

    elsif e.is_a?(CopyrightedResource)
      resource = e.resource
      @new_url = url_for safe_params.merge(resource_id_key => resource.to_param)

      if params[:format] == 'rss'
        redirect_to @new_url, status: 301
      else
        render 'pages/page_moved.html', layout: false, status: 404, formats: :html
      end

    else
      if self.kind_of?(Api::V1Controller) || json?
        render(
          json: {
            code: 503,
            exception: e.class.name,
            message: e.message,
            backtrace: e.backtrace.first.sub(Rails.root.to_s, '')
          },
          status: 503
        )
      else
        @page_title = t 'error'
        render 'pages/page503.html', layout: false, status: 503, formats: :html
      end
    end
  end
end
