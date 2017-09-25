class Neko::Achievements
  method_object %i[user! user_rate action]

  def call
    Neko::Apply.call(
      @user,
      Neko::Request.call(neko_params(@user, @user_rate, @action))
    )
  end

private

  def neko_params user, user_rate, action
    params = { user_id: user.id, action: action }
    params[:id] = user_rate.id if user_rate
    params
  end
end
