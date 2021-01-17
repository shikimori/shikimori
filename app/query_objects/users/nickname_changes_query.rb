class Users::NicknameChangesQuery
  method_object :user, :is_moderator

  def call
    scope =
      if @is_moderator
        UserNicknameChange.unscoped.where(user: @user)
      else
        @user.nickname_changes
      end

    scope
      .where.not(value: @user.nickname)
      .order(id: :desc)
  end
end
