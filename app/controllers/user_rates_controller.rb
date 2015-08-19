require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

# TODO: refactor list import into service object
class UserRatesController < ProfilesController
  load_and_authorize_resource except: [:index, :export, :import]

  before_action :authorize_list_access, only: [:index, :export, :import]
  before_action :set_sort_order, only: [:index], if: :user_signed_in?
  after_action :save_sort_order, only: [:index], if: :user_signed_in?

  skip_before_action :fetch_resource, :set_breadcrumbs, except: [:index, :export, :import]

  def index
    noindex
    @page = (params[:page] || 1).to_i
    @limit = UserListDecorator::ENTRIES_PER_PAGE
    @genres, @studios, @publishers = AniMangaAssociationsQuery.new.fetch params[:list_type].capitalize.constantize

    page_title t("#{params[:list_type]}_list")
  end

  def create
    if (@user_rate.save rescue PG::Error)
      render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
    else
      render json: @user_rate.errors.full_messages, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user_rate.update update_params
      render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
    else
      render json: @user_rate.errors.full_messages, status: :unprocessable_entity
    end
  end

  def increment
    if @user_rate.anime?
      @user_rate.update episodes: @user_rate.episodes + 1
    else
      @user_rate.update chapters: @user_rate.chapters + 1
    end

    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def destroy
    @user_rate.destroy!
    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def export
    type = params[:list_type]
    if type == 'anime'
      @klass = Anime
      @list = @resource.anime_rates.includes(:anime)
    else
      @klass = Manga
      @list = @resource.manga_rates.includes(:manga)
    end

    response.headers['Content-Description'] = 'File Transfer'
    response.headers['Content-Disposition'] = "attachment; filename=#{type}list.xml"
    render :export, formats: :xml
  end

  # импорт списка
  def import
    authorize! :update, @resource

    klass = Object.const_get(params[:klass].capitalize)
    rewrite = params[:rewrite] == true || params[:rewrite] == '1'

    # в ситуации, когда через yql не получилось, можно попробовать вручную скачать список
    #if params[:mal_login].present?
      #params[:file] = open "http://myanimelist.net/malappinfo.php?u=#{params[:mal_login]}&status=all&type=#{params[:klass]}"
      #params[:list_type] = 'xml'
    #end

    parser = UserListParser.new klass
    importer = UserRatesImporter.new @resource, klass
    @added, @updated, @not_imported = importer.import(parser.parse(params), rewrite)

    if @added.size > 0 || @updated.size > 0
      @resource.touch
      UserHistory.create(
        user_id: @resource.id,
        action: UserHistoryAction.const_get("#{params[:list_type].to_sym == :mal || params[:list_type].to_sym == :xml ? 'Mal' : 'Ap'}#{klass.name}Import"),
        value: @added.size + @updated.size
      )
    end

    message = []

    if @added.size > 0
      items = klass.where(id: @added).select([:id, :name])
      if klass == Manga
        message << "В ваш список #{Russian.p(@added.size, 'импортирована', 'импортированы', 'импортированы')} #{@added.size} #{Russian.p(@added.size, 'манга', 'манги', 'манги')}:"
      else
        message << "В ваш список #{Russian.p(@added.size, 'импортировано', 'импортированы', 'импортированы')} #{@added.size} #{Russian.p(@added.size, 'аниме', 'аниме', 'аниме')}:"
      end
      message = message + items.sort_by {|v| v.name }.map {|v| "<a class=\"bubbled\" href=\"#{url_for v}\">#{v.name}</a>" }
      message << ''
    end

    if @updated.size > 0
      items = klass.where(id: @updated).select([:id, :name])
      if klass == Manga
        message << "В вашем списке #{Russian.p(@updated.size, 'обновлена', 'обновлены', 'обновлены')} #{@updated.size} #{Russian.p(@updated.size, 'манга', 'манги', 'манги')}:"
      else
        message << "В вашем списке #{Russian.p(@updated.size, 'обновлено', 'обновлены', 'обновлены')} #{@updated.size} #{Russian.p(@updated.size, 'аниме', 'аниме', 'аниме')}:"
      end
      message = message + items.sort_by {|v| v.name }.map {|v| "<a class=\"bubbled\" href=\"#{url_for v}\">#{v.name}</a>" }
      message << ''
    end

    if @not_imported.size > 0
      message << "Не удалось импортировать (распознать) #{@not_imported.size} #{klass == Manga ? Russian.p(@not_imported.size, 'мангу', 'манги', 'манги') : 'аниме'}. Пожалуйста, добавьте их в свой список самостоятельно:"
      message = message + @not_imported.sort
    end
    message << "Ничего нового не импортировано." if message.empty?

    poster = BotsService.get_poster
    messages = message.each_slice(400).to_a.reverse
    messages.each_with_index do |message,index|
      message = ['(продолжение предыдущего сообщения)<br>'] + message if index != messages.size - 1
      Message.create!(
        from_id: poster.id,
        to_id: @resource.id,
        kind: MessageType::Private,
        body: message.join('<br>')
      )
      sleep(1)
    end

    redirect_to profile_dialogs_url(@resource)

  rescue Exception => e
    if Rails.env.production?
      #ExceptionNotifier.notify_exception(e, env: request.env, data: { nickname: user_signed_in? ? @resource.nickname : nil })
      Honeybadger.notify(e, env: request.env, data: { nickname: user_signed_in? ? @resource.nickname : nil })
      redirect_to :back, alert: 'Произошла ошибка. Возможно, некорректный формат файла.'
    else
      raise
    end
  end

private

  def create_params
    params.require(:user_rate).permit *Api::V1::UserRatesController::CREATE_PARAMS
  end

  def update_params
    params.require(:user_rate).permit *Api::V1::UserRatesController::UPDATE_PARAMS
  end

  def authorize_list_access
    authorize! :access_list, @resource
  end

  def set_sort_order
    params[:order] ||= current_user.preferences.default_sort
  end

  def save_sort_order
    if current_user.preferences.default_sort != params[:order]
      current_user.preferences.update default_sort: params[:order]
    end
  end
end
