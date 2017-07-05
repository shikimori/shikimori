class Users::LogNicknameChange
  method_object :user, :old_nickname

  def call
    return unless @user.day_registered?
    UserNicknameChange.create user: user, value: old_nickname
    friends.each { |friend| notify_friend friend }
  end

private

  def friends
    FriendLink
      .where(dst_id: user.id)
      .includes(:src)
      .map(&:src)
  end

  def notify_friend friend
    Messages::CreateNotification.new(user).nickname_changed(
      friend,
      @old_nickname,
      @user.nickname
    )
  rescue ActiveRecord::RecordNotUnique
    nil
  end
end
