class Api::V1::FriendsController < Api::V1Controller
  before_action :authenticate_user!
  before_action :fetch_user

  SPAM_LIMIT = 20

  before_action only: %i[create destroy] do
    doorkeeper_authorize! :friends_ignores if doorkeeper_token.present?
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :POST, '/friends/:id', 'Create a friend'
  description 'Requires `friends_ignores` oauth scope'
  def create
    current_user.friends << @user

    # если дружба не взаимная, то надо создать сообщение с запросом в друзья
    unless @user.friends.include? current_user
      Message
        .where(from_id: current_user.id, to_id: @user.id)
        .where(kind: MessageType::FRIEND_REQUEST)
        .delete_all

      if @user.id != 1 && !spam? # no friend requests for morr
        Message.create(
          from_id: current_user.id,
          to_id: @user.id,
          kind: MessageType::FRIEND_REQUEST
        )
      end
    end
  rescue ActiveRecord::RecordNotUnique
  ensure
    render json: { notice: add_notice }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/friends/:id', 'Destroy a friend'
  description 'Requires `friends_ignores` oauth scope'
  def destroy
    current_user.friends.delete @user

    render json: { notice: remove_notice }
  end

private

  def fetch_user
    @user ||= User.find_by(id: params[:id]) ||
      User.find_by!(nickname: User.param_to(params[:id]))
  end

  def add_notice
    i18n_t(
      "added_to_friends.#{@user.sex.present? ? @user.sex : 'male'}",
      nickname: @user.nickname
    )
  end

  def remove_notice
    i18n_t(
      "removed_from_friends.#{@user.sex.present? ? @user.sex : 'male'}",
      nickname: @user.nickname
    )
  end

  def spam?
    Message
      .where(from_id: current_user.id, kind: MessageType::FRIEND_REQUEST)
      .where('created_at > ?', 1.day.ago)
      .size >= SPAM_LIMIT
  end
end
