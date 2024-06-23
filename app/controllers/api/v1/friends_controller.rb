class Api::V1::FriendsController < Api::V1Controller
  before_action :authenticate_user!
  before_action :fetch_user

  SPAM_LIMIT = 20

  before_action do
    doorkeeper_authorize! :friends if doorkeeper_token.present?
  end

  api :POST, '/friends/:id', 'Create a friend'
  description 'Requires `friends` oauth scope'
  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @resource = FriendLink.new src: current_user, dst: @user

    if @resource.save
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
    else
      render json: { errors: @resource.errors.full_messages },
        status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
  ensure
    render json: { notice: add_notice }
  end

  api :DELETE, '/friends/:id', 'Destroy a friend'
  description 'Requires `friends` oauth scope'
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
      "added_to_friends.#{@user.sex.presence || 'male'}",
      nickname: @user.nickname
    )
  end

  def remove_notice
    i18n_t(
      "removed_from_friends.#{@user.sex.presence || 'male'}",
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
