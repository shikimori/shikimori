class Api::V1::DialogsController < Api::V1::ApiController
  MESSAGES_PER_PAGE = 10

  respond_to :json
  before_action :authorize_messages_access
  before_action :fetch_target_user, only: [:show, :destroy]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/dialogs', 'List dialogs'
  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    @collection = DialogsQuery.new(current_user).fetch(@page, @limit)

    respond_with @collection, each_serializer: DialogSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/dialogs/:id', 'Show a dialog'
  def show
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    @collection = DialogQuery
      .new(current_user, @target_user)
      .fetch(@page, @limit, false)
      .reverse

    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/dialogs/:id', 'Destroy a dialog'
  def destroy
    message = Message.find_by(from: current_user, to: @target_user, kind: MessageType::Private) ||
      Message.find_by(to: current_user, from: @target_user, kind: MessageType::Private)

    if message
      Dialog.new(current_user, message).destroy
      render json: { notice: i18n_t('conversation_removed') }
    else
      render json: [i18n_t('no_messages')],
        status: :unprocessable_entity
    end
  end

private

  def authorize_messages_access
    authorize! :access_messages, current_user
  end

  def fetch_target_user
    @target_user = User.find_by(id: params[:id]) || User.find_by(nickname: User.param_to(params[:id])) || raise(NotFound, params[:id])
  end
end
