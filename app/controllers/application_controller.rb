class StatusCodeError < StandardError; end

class ApplicationController < ActionController::Base
  include SEO

  protect_from_forgery

  layout :layout_by_xhr
  before_filter :fix_googlebot
  before_filter :update_last_online if Rails.env != 'test'
  before_filter :mailer_set_url_options
  before_filter :force_vary_accept
  #before_filter :authorize_rack_mini_profiler if Rails.env.development?

  helper_method :resource_class
  helper_method :remote_addr
  helper_method :json?

  before_filter :logging
  def logging
    #logger.info "[PID:#{Process.pid}]" if logger
    logger.info "[USER:#{current_user.id}] #{current_user.nickname}" if logger && user_signed_in?
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def fix_googlebot
    if request.format.to_s =~ %r%\*\/\*%
      request.format = :html
    end
  end

  #if Rails.env == 'development'
    #def current_user
      #return User.find_by_nickname('Daiver')
    #end
  #end

  #unless ['test', 'development'].include? Rails.env
  unless Rails.env.test?
    rescue_from Exception, with: :runtime_error
    rescue_from SyntaxError, with: :runtime_error
    rescue_from Mysql2::Error, with: :runtime_error
    rescue_from NoMethodError, with: :runtime_error
    rescue_from ActionController::RoutingError, with: :runtime_error
    rescue_from AbstractController::ActionNotFound, with: :runtime_error
    rescue_from ActionView::Template::Error, with: :runtime_error
  else
    rescue_from StatusCodeError, with: :runtime_error
  end

  def runtime_error(e)
    ExceptionNotifier.notify_exception(e, env: request.env, data: {
      nickname: user_signed_in? ? current_user.nickname : nil
    })

    raise e if remote_addr == '127.0.0.1'

    #logger.error e.message
    #logger.error e.backtrace.join("\n")

    if [ActionController::RoutingError, ActiveRecord::RecordNotFound, AbstractController::ActionNotFound, NotFound].include?(e.class)
      @page_title = "Страница не найдена"
      @sub_layout = nil
      render 'pages/page404.html', layout: 'application', status: 404
    elsif e.is_a?(Forbidden)
      render text: e.message, status: e.status
    elsif e.is_a?(StatusCodeError)
      render json: {}, status: e.status
    else
      @page_title = "Ошибка"
      logger.error e.message
      logger.error e.backtrace.join("\n")
      render 'pages/page503.html', layout: 'application', status: 503
    end
  end

  def update_last_online
    return unless user_signed_in? && !params.include?(:format) && current_user.class != Symbol
    current_user.update_last_online if current_user.id != 1
  end

  #def http_status_code(e)
    #logger.info(e.class)
    #logger.info(e.status)
    ##Xmpp.message e.class
    ##Xmpp.message e.status
    #render json: {}, status: e.status
    ##respond_to do |format|
      ##format.html { render template: "shared/status_#{status.to_s}", status: status }
      ##format.any  { head status } # only return the status code
    ##end
  #end

  #def local_request?
    #false
  #end

  #def rescue_action_in_public(exception)
    #case exception
    #when ActiveRecord::RecordNotFound
      #Xmpp.send "test"
      #render file: "#{RAILS_ROOT}/public/404.html", status: 404
    #else
      #super
    #end
  #end

  def debug(object)
    render inline: '<%=debug(object) %>', locals: {object: object}
  end

  def chronology(params)
    collection = params[:source]
        .where("`#{params[:date]}` >= #{Entry.sanitize params[:entry][params[:date]]}")
        .where("#{params[:entry].class.table_name}.id != #{Entry.sanitize params[:entry].id}")
        .limit(20)
        .order(params[:date])
        .all + [params[:entry]]

    collection += params[:source]
        .where("`#{params[:date]}` <= #{Entry.sanitize params[:entry][params[:date]]}")
        .where { id.not_in collection.map(&:id) }
        .limit(20)
        .order("#{params[:date]} desc")
        .all

    collection = collection.sort {|l,r| r[params[:date]] == l[params[:date]] ? r.id <=> l.id : r[params[:date]] <=> l[params[:date]] }
    collection = collection.reverse if params[:desc]
    gallery_index = collection.index {|v| v.id == params[:entry].id }
    reduce = Proc.new {|v| v < 0 ? 0 : v }
    collection.slice(reduce.call(gallery_index + params[:window] + 1 < collection.size ?
                                   gallery_index - params[:window] :
                                   (gallery_index - params[:window] - (gallery_index + params[:window]  + 1 - collection.size))),
                     params[:window]*2 + 1).
               group_by do |v|
                 Russian::strftime(v[params[:date]], '%B %Y')
               end
  end

  # для руссификации
  I18n.exception_handler = lambda do |exception, locale, key, options|
    raise "missing translation #{locale} #{key}"# unless Rails.env.production?
    #case exception
      #when I18n::MissingTranslationData, I18n::MissingTranslation
        #unless locale == :en
          #I18n.translate key, (options || {}).merge(locale: :en)
          #ExceptionNotifier.notify_exception exception
        #else
          #key
        #end

      #else
        #raise exception.message
    #end
  end

  # создание презентера
  def present(object, klass = nil)
    klass ||= case object.class.name
      when Anime.name, Manga.name
        AniMangaPresenter

      when Person.name
        if object.seyu && !object.producer && !object.mangaka
          SeyuPresenter
        else
          PersonPresenter
        end

      else
        "#{object.class.model_name}Presenter".constantize
    end

    klass.new object, view_context
  end

  # создание директора
  def direct(object=nil)
    klass = "#{self.class.name.sub(/Controller$/, '').sub(/^(Animes|Mangas)$/, 'AniMangas').sub(/Controller::/, 'Director::')}Director".constantize
    director = klass.new(self)
    director.send params[:action]
    director
  end

  def _log(*args)
    Rails.logger.info '-----------------'
    Rails.logger.info *args
    Rails.logger.info '-----------------'
  end

  # хром некорректно обрабатывает Back кнопку, если на аякс ответ не послан заголовок Vary: Accept
  def force_vary_accept
    if json?
      response.headers['Vary'] = 'Accept'
      response.headers['Pragma'] = 'no-cache' if request.env['HTTP_USER_AGENT'] =~ /Firefox/
    end
  end

private
  def check_auth
    raise Unauthorized unless user_signed_in?
  end

  def layout_by_xhr
    if request.xhr?
      false
    else
      'application'
    end
  end

  def check_post_permission
    raise Forbidden, "Вы забанены (запрет комментирования) до #{current_user.read_only_at.strftime '%H:%M %d.%m.%Y'}" unless current_user.can_post?
  end

  # пагинация датасорса
  # задаёт переменные класса @page, @limit, @add_postloader
  def postload_paginate(page, limit)
    @page = (page || 1).to_i
    @limit = limit.to_i

    ds = yield

    entries = ds.offset(@limit * (@page-1)).limit(@limit + 1).all
    @add_postloader = entries.size > @limit

    @add_postloader ? entries.take(limit) : entries
  end

  # корректно определяющийся ip адрес пользователя
  def remote_addr
    ip = request.headers['HTTP_X_FORWARDED_FOR'] || request.headers['HTTP_X_REAL_IP'] || request.headers['REMOTE_ADDR']
    ip = ip+'z' if user_signed_in? && [296, 3801].include?(current_user.id)
    ip
  end

  def json?
    request.format == Mime::Type.lookup_by_extension('json') || params[:format] == 'json'
  end

  def redirect_to_back_or_to(default, *args)
    if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      redirect_to :back, *args
    else
      redirect_to default, *args
    end
  end

  #def authorize_rack_mini_profiler
    #Rack::MiniProfiler.authorize_request if user_signed_in? && current_user.admin?
  #end
end
