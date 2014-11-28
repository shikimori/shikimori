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

    @dialog = Dialog.new(@resource, Message.new(to_id: params[:id].to_i, from_id: @resource.id))

    @collection, @add_postloader = DialogQuery
      .new(@resource, @dialog.target_user)
      .postload(@page, @limit)

    page_title "Диалог с #{@dialog.target_user.nickname}"
  end

  def destroy
    message = Message.find params[:id]
    Dialog.new(@resource, message).destroy

    render json: { notice: 'Диалог удалён' }
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
