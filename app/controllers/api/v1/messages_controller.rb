class Api::V1::MessagesController < Api::V1::ApiController
  load_and_authorize_resource except: [:read_all, :delete_all]
  before_action :prepare_group_action, only: [:read_all, :delete_all]
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/messages', 'Create a message'
  param :message, Hash do
    param :body, :undef
    param :from_id, :number
    param :kind, :undef
    param :to_id, :number
  end
  def create
    faye.create @resource
    respond_with @resource.decorate
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PATCH, '/messages/:id', 'Update a message'
  api :PUT, '/messages/:id', 'Update a message'
  param :message, Hash do
    param :body, :undef
  end
  def update
    faye.update @resource, update_params
    respond_with @resource.decorate
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/messages/:id', 'Destroy a message'
  def destroy
    faye.destroy @resource
    respond_with @resource.decorate
  end

  api :POST, '/messages/mark_read', 'Mark messages as read or unread'
  param :ids, :undef
  def mark_read
    ids = (params[:ids] || '').split(',').map(&:to_i)

    Message
      .where(id: ids, to_id: current_user.id)
      .update_all(read: params[:is_read] == '1')

    head 200
  end

  api :POST, '/messages/read_all', 'Mark all messages as read. Types: news, notifications'
  param :type, :undef
  param :profile_id, :undef
  def read_all
    MessagesService.new(current_user).read_messages type: @message_type
    head 200
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/messages/delete_all', 'Delete all messages. Types: news, notifications'
  param :profile_id, :undef
  param :type, :undef
  def delete_all
    MessagesService.new(current_user).delete_messages type: @message_type
    head 200
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

    @message_type = case params[:type].to_sym
      when :news then :news
      when :notifications then :notifications
      else raise CanCan::AccessDenied
    end
  end

  def faye
    FayeService.new current_user, nil
  end
end
