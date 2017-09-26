class Neko::Update
  method_object :user, %i[user_rate_id action]

  def call
    Neko::Apply.call(
      @user,
      Neko::Request.call(neko_params(@user, @user_rate_id, @action))
    )
  end

private

  def neko_params user, user_rate_id, action
    params = { user_id: user.id, action: action }
    params[:id] = user_rate_id if user_rate_id
    params
  end
end
