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
    params = { user_id: user.id, action: }

    if user_rate_id
      params[:id] = user_rate_id
      params = params.merge(user_rate_params(user_rate_id)) if action == Types::Neko::Action[:put]
    end

    params
  end

  def user_rate_params user_rate_id
    user_rate = UserRate.find user_rate_id

    {
      id: user_rate_id,
      target_id: user_rate.target_id,
      score: user_rate.score,
      status: user_rate.status,
      episodes: user_rate.episodes
    }
  rescue ActiveRecord::RecordNotFound
    { action: Types::Neko::Action[:delete] }
  end
end
