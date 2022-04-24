class ApplicationController < ActionController::Base
  include Translation
  include ErrorsConcern
  include UrlsConcern
  include OpenGraphConcern
  include BreadcrumbsConcern
  include InvalidParameterErrorConcern
  include DomainsConcern
  include LocaleConcern
  include PaginationConcern
  include StorableLocationConcern
  include AgeRestrictionsConcern

  protect_from_forgery with: :exception, prepend: true # https://stackoverflow.com/questions/43356105/actioncontrollerinvalidauthenticitytoken-rails-5-devise-audited-papertra

  layout :set_layout

  before_action do
    @layout = ::LayoutView.new
    @top_menu = ::Menus::TopMenu.new
  end

  before_action :fix_googlebot
  before_action :touch_last_online
  before_action :mailer_set_url_options
  before_action :force_vary_accept
  before_action :force_no_cache, unless: :user_signed_in?

  helper_method :resource_class
  helper_method :json?
  helper_method :adaptivity_class
  helper_method :turbolinks_request?
  helper_method :base_controller_names
  # helper_method :ignore_copyright?

  helper_method :i18n_i, :i18n_io, :i18n_v

  I18n.exception_handler = ->(_exception, locale, key, _options) {
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
  rescue ActionDispatch::Http::Parameters::ParseError
    nil
  end

  def sign_out *args
    result = super(*args)
    @decorated_current_user = nil
    result
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

  # before фильтры с настройкой сайта
  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  # гугловский бот со странным format иногда ходит
  def fix_googlebot
    request.format = :html if request.format.to_s =~ %r{\*/\*}
  end

  # хром некорректно обрабатывает Back кнопку,
  # если на аякс ответ не послан заголовок Vary: Accept
  def force_vary_accept
    if json?
      response.headers['Vary'] = 'Accept'

      if request.env['HTTP_USER_AGENT']&.match?(/Firefox/)
        response.headers['Pragma'] = 'no-cache'
      end
    end
  end

  def force_no_cache
    # https://github.com/rails/rails/issues/21948
    # https://blog.alex-miller.co/rails/2017/01/07/rails-authenticity-token-and-mobile-safari.html
    if request.env['HTTP_USER_AGENT']&.match?(/PlayStation|Android|Mobile Safari/)
      response.headers['Cache-Control'] = 'no-store, no-cache'
    end
  end

  def touch_last_online
    return unless user_signed_in? && current_user.class != Symbol

    current_user.update_last_online
  end

  def xhr_or_json?
    request.xhr? || json?
  end

  def json?
    request.format == Mime::Type.lookup_by_extension('json') ||
      params[:format] == 'json'
  end

  # def ignore_copyright?
  #   !clean_host?
  #   # ru_host? && !clean_host? && (
  #   #   current_user&.day_registered? ||
  #   #   GeoipAccess.instance.anime_online_allowed?(request.remote_ip) ||
  #   #   Rails.env.development?
  #   # )
  # end

  def faye_token
    request.headers['X-Faye-Token'] || params[:faye]
  end
end
