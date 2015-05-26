class Api::V1::FriendsController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/friends/:id', 'Create a friend'
  def create
    @user = User.find params[:id]

    if current_user.friends.include?(@user)
      render json: [
        "#{@user.nickname} уже среди ваших друзей"
      ], status: :unprocessable_entity
    else
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

      render json: {
        notice: "#{@user.nickname} добавлен#{'а' if @user.female?} в друзья"
      }
    end
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/friends/:id', 'Destroy a friend'
  def destroy
    @user = User.find(params[:id])

    current_user.friends.delete @user
    render json: {
      notice: "#{@user.nickname} удален#{'а' if @user.female?} из друзей"
    }
  end
end
