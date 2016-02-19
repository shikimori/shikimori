class Api::V1::FriendsController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/friends/:id', 'Create a friend'
  def create
    @user = User.find params[:id]
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

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/friends/:id', 'Destroy a friend'
  def destroy
    @user = User.find(params[:id])
    current_user.friends.delete @user

    notice = i18n_t(
      "removed_from_friends.#{@user.sex || 'male'}",
      nickname: @user.nickname
    )

    render json: { notice: notice }
  end

private

  def success_notice
    i18n_t(
      "added_to_friends.#{@user.sex || 'male'}",
      nickname: @user.nickname
    )
  end
end
