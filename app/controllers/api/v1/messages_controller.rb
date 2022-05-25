class Api::V1::MessagesController < Api::V1Controller # rubocop:disable ClassLength
  load_and_authorize_resource except: %i[read_all delete_all]
  before_action :prepare_group_action, only: %i[read_all delete_all]
  before_action :check_antispam, only: %i[create], unless: :user_signed_in?
  before_action :append_info, only: %i[create]

  ANTISPAM_TOKEN_NAME = 'bde0c23a4b6c2e99z6a14003ce1d728d319'
  ANTISPAM_TOKEN_VALUE = '34f91ea4f1fa09e443f820b4ac5cf3d9dca'

  before_action do
    doorkeeper_authorize! :messages if doorkeeper_token.present?
  end

  api :GET, '/messages/:id', 'Show a message'
  description 'Requires `messages` oauth scope'
  def show
    respond_with @resource.decorate
  end

  api :POST, '/messages', 'Create a message'
  description 'Requires `messages` oauth scope'
  param :message, Hash do
    param :body, String, required: true
    param :from_id, :number, required: true
    param :kind, [MessageType::PRIVATE], required: true
    param :to_id, :number, required: true
  end
  error code: 422
  def create
    if faye.create @resource
      if frontent_request?
        render :message, locals: { notice: i18n_t('message.created') }
      else
        respond_with @resource.decorate
      end
    else
      render json: {
        errors: @resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  api :PATCH, '/messages/:id', 'Update a message'
  api :PUT, '/messages/:id', 'Update a message'
  description 'Requires `messages` oauth scope'
  param :message, Hash, required: true do
    param :body, String, required: true
  end
  error code: 422
  def update
    if faye.update @resource, update_params
      if frontent_request?
        render :message, locals: { notice: i18n_t('message.updated') }
      else
        respond_with @resource.decorate
      end
    else
      render json: {
        errors: @resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  api :DELETE, '/messages/:id', 'Destroy a message'
  description 'Requires `messages` oauth scope'
  def destroy
    faye.destroy @resource

    if frontent_request?
      render json: { notice: i18n_t('message.removed') }
    else
      respond_with @resource.decorate
    end
  end

  api :POST, '/messages/mark_read', 'Mark messages as read or unread'
  description 'Requires `messages` oauth scope'
  param :ids, :undef
  def mark_read
    ids = (params[:ids] || '').split(',').map { |v| v.sub(/message-/, '').to_i }

    MessagesService
      .new(current_user)
      .read_by(ids: ids, is_read: params[:is_read] == '1')

    head 200
  end

  api :POST, '/messages/read_all', 'Mark all messages as read'
  description 'Requires `messages` oauth scope'
  param :type, %w[news notifications], required: true
  def read_all
    MessagesService
      .new(current_user)
      .read_by(type: @messages_type, is_read: true)

    if frontent_request?
      redirect_back(
        fallback_location: index_profile_messages_url(
          current_user,
          messages_type: @messages_type
        ),
        notice: i18n_t('messages.read')
      )
    else
      head 200
    end
  end

  api :POST, '/messages/delete_all', 'Delete all messages'
  description 'Requires `messages` oauth scope'
  param :frontend, :bool, 'Used by shikimori frontend code. Ignore it.'
  param :type, %w[news notifications], required: true
  error code: 302
  def delete_all
    MessagesService.new(current_user).delete_by type: @messages_type

    if frontent_request?
      redirect_back(
        fallback_location: index_profile_messages_url(
          current_user, messages_type: @messages_type
        ),
        notice: i18n_t('messages.removed')
      )
    else
      head 200
    end
  end

private

  def create_params
    params
      .require(:message)
      .permit(:kind, :from_id, :to_id, :body)
  end

  def update_params
    params.require(:message).permit(:body)
  end

  def prepare_group_action
    authorize! :access_messages, current_user

    @messages_type = case params[:type].to_sym
      when :news then :news
      when :notifications then :notifications
      else raise CanCan::AccessDenied
    end
  end

  def check_antispam
    if params[ANTISPAM_TOKEN_NAME] != ANTISPAM_TOKEN_VALUE
      render json: ['antispam check error'], status: :unprocessable_entity
    end
  end

  def faye
    FayeService.new current_user || User.find(User::GUEST_ID), faye_token
  end

  def append_info
    return unless @resource.to&.admin?

    @resource.body = @resource.body.strip + info_text
  end

  def info_text
    info = [
      "#{location_text}#{feedback_address_text}",
      params[:message][:user_agent] || request.env['HTTP_USER_AGENT'],
      request.remote_ip
    ].select(&:present?).join("\n")

    "\n" + <<~TEXT.strip
      [right][size=11][color=gray][spoiler=info][quote]
      #{info}
      [/quote][/spoiler][/color][/size][/right]
    TEXT
  end

  def location_text
    return if params[:message][:location].blank?

    "[url=#{params[:message][:location]}]#{params[:message][:location]}[/url]\n"
  end

  def feedback_address_text
    return if params[:message][:feedback_address].blank?

    "#{params[:message][:feedback_address]}\n"
  end
end
