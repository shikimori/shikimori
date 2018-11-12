class DialogsController < ProfilesController
  before_action :authorize_messages_access
  before_action :add_title
  before_action :add_breadcrumb, only: [:show]

  MESSAGES_PER_PAGE = 10

  def index
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    @collection, @add_postloader = DialogsQuery.new(@resource).postload @page, @limit
  end

  def show
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    target_user = User.find_by!(nickname: User.param_to(params[:id]))
    @dialog = Dialog.new(@resource, Message.new(to_id: target_user.id, from_id: @resource.id))
    @replied_message = if params[:reply_message_id]
      message = Message.find_by(id: params[:reply_message_id])
      message if message && can?(:read, message)
    end

    @collection, @add_postloader = DialogQuery
      .new(@resource, @dialog.target_user)
      .postload(@page, @limit)

    @collection = @collection.map(&:decorate)

    og page_title: "Диалог с #{@dialog.target_user.nickname}"
  end

  def destroy
    Dialog.new(@resource, Message.find(params[:id])).destroy

    render json: { notice: i18n_t('conversation_removed') }
  end

private

  def authorize_messages_access
    authorize! :access_messages, @resource
  end

  def add_title
    og page_title: t(:mail)
  end

  def add_breadcrumb
    breadcrumb t(:mail), profile_dialogs_url(@resource)
    @back_url = profile_dialogs_url(@resource)
  end
end
