class ApplicationController < ActionController::Base
  include Mobylette::RespondToMobileRequests

  protect_from_forgery with: :exception

  layout :set_layout
  before_action :fix_googlebot
  before_action :touch_last_online unless Rails.env.test?
  before_action :mailer_set_url_options
  before_action :force_vary_accept

  helper_method :url_params
  helper_method :resource_class
  helper_method :remote_addr
  helper_method :json?
  helper_method :domain_folder
  helper_method :adaptivity_class
  helper_method :shikimori?
  helper_method :anime_online?
  helper_method :manga_online?
  helper_method :turbolinks_request?
  helper_method :base_controller_name

  unless Rails.env.test?
    rescue_from AbstractController::ActionNotFound, AbstractController::Error, ActionController::InvalidAuthenticityToken,
      ActionController::RoutingError, ActionView::MissingTemplate, ActionView::Template::Error, Exception, PG::Error,
      Encoding::CompatibilityError, NoMethodError, StandardError, SyntaxError, CanCan::AccessDenied, with: :runtime_error
  else
    rescue_from StatusCodeError, with: :runtime_error
  end

  I18n.exception_handler = -> (exception, locale, key, options) {
    raise ArgumentError, "#{locale} #{key}"
  }

  def runtime_error e
    ExceptionNotifier.notify_exception(e, env: request.env, data: { nickname: user_signed_in? ? current_user.nickname : nil })
    notify_honeybadger(e) if respond_to?(:notify_honeybadger)

    NamedLogger.send("#{Rails.env}_errors").error "#{e.message}\n#{e.backtrace.join("\n")}"
    Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"

    raise e if remote_addr == '127.0.0.1'

    if [ActionController::RoutingError, ActiveRecord::RecordNotFound, AbstractController::ActionNotFound, ActionController::UnknownFormat, NotFound].include?(e.class)
      @page_title = 'Страница не найдена'
      @sub_layout = nil
      render 'pages/page404.html', layout: false, status: 404

    elsif e.is_a?(Forbidden) || e.is_a?(CanCan::AccessDenied)
      render text: e.message, status: 403

    elsif e.is_a?(StatusCodeError)
      render json: {}, status: e.status

    else
      @page_title = 'Ошибка'
      render 'pages/page503.html', layout: false, status: 503
    end
  end

  # хелпер для перевода params к виду, который можно засунуть в url хелперы
  def url_params merged=nil
    cloned_params = params.clone.except(:action, :controller).symbolize_keys
    merged ? cloned_params.merge(merged) : cloned_params
  end

  # находимся ли сейчас на домене шикимори?
  def shikimori?
    ShikimoriDomain::HOSTS.include? request.host
  end

  # находимся ли сейчас на домене аниме?
  def anime_online?
    AnimeOnlineDomain::HOSTS.include? request.host
  end

  # находимся ли сейчас на домене манги?
  def manga_online?
    MangaOnlineDomain::HOSTS.include? request.host
  end

  # запрос ли это через турболинки
  def turbolinks_request?
    request.headers['X-XHR-Referer'].present?
  end

  def current_user
    @decorated_current_user ||= super.try :decorate
  end

  # каталог текущего домена
  def domain_folder
    if anime_online?
      'anime_online'
    elsif manga_online?
      'manga_online'
    else
      'shikimori'
    end
  end

  def base_controller_name
    name = self.class.superclass.name.to_underscore.sub(/_controller$/, '')
    name if name != 'application' && name != 'shikimori'
  end

private
  def set_layout
    if request.xhr?
      false
    else
      'application'
    end
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
    return unless user_signed_in? && !params.include?(:format) && current_user.class != Symbol
    current_user.update_last_online if current_user.id != 1
  end

  # корректно определяющийся ip адрес пользователя
  def remote_addr
    ip = request.headers['HTTP_X_FORWARDED_FOR'] || request.headers['HTTP_X_REAL_IP'] || request.headers['REMOTE_ADDR']
    ip = ip+'z' if user_signed_in? && [231, 296, 3801, 16029].include?(current_user.id)
    ip
  end

  def json?
    request.format == Mime::Type.lookup_by_extension('json') || params[:format] == 'json'
  end

  # faye токен текущего пользователя
  def faye_token
    request.headers['X-Faye-Token'] || params[:faye]
  end
end
