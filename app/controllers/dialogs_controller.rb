# TODO: отрефакторить толстый контроллер
# TODO: спеки на все методы контроллера
class DialogsController < ProfilesController
  before_action :authorize_messages_access, only: [:index]
  before_action :add_title
  before_action :add_breadcrumb, only: [:show]

  MESSAGES_PER_PAGE = 10

  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    @collection, @add_postloader = DialogsQuery.new(@resource).postload @page, @limit
  end

  def show
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    @target_user = User.find params[:id]
    @collection, @add_postloader = DialogQuery.new(@resource, @target_user).postload @page, @limit

    #@thread = TopicProxyDecorator.new object
    #@thread.preview_mode!
    #@thread

    page_title "Диалог с #{@target_user.nickname}"
  end

  def destroy
  end

private
  def authorize_messages_access
    authorize! :access_messages, @resource
  end

  def add_title
    page_title 'Почта'
  end

  def add_breadcrumb
    breadcrumb 'Почта', profile_dialogs_url(@resource)
    @back_url = profile_dialogs_url(@resource)
  end
end
