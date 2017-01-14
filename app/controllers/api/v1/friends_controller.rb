class Api::V1::FriendsController < Api::V1Controller
  before_action :authenticate_user!
  before_action :fetch_user

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :POST, '/friends/:id', 'Create a friend'
  def create
    current_user.friends << @user

    # если дружба не взаимная, то надо создать сообщение с запросом в друзья
    unless @user.friends.include? current_user
      Message
        .where(from_id: current_user.id, to_id: @user.id)
        .where(kind: MessageType::FriendRequest)
        .delete_all

      Message.create(
        from_id: current_user.id,
        to_id: @user.id,
        kind: MessageType::FriendRequest
      )
    end

  rescue ActiveRecord::RecordNotUnique
  ensure
    render json: { notice: success_notice }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/friends/:id', 'Destroy a friend'
  def destroy
    current_user.friends.delete @user

    notice = i18n_t(
      "removed_from_friends.#{@user.sex || 'male'}",
      nickname: @user.nickname
    )

    render json: { notice: notice }
  end

private

  def fetch_user
    @user ||= User.find_by(id: params[:id]) ||
      User.find_by(nickname: User.param_to(params[:id])) ||
      raise(NotFound, params[:id])
  end

  def success_notice
    i18n_t(
      "added_to_friends.#{@user.sex || 'male'}",
      nickname: @user.nickname
    )
  end
end
