class IgnoresController < ShikimoriController
  before_filter :authenticate_user!

  def create
    @user = User.find(params[:id])

    if current_user.ignores?(@user)
      render json: [
        "Сообщения от #{@user.nickname} уже блокируются"
      ], status: :unprocessable_entity
    else
      current_user.ignored_users << @user

      render json: {
        notice: "Сообщения от #{@user.nickname} заблокированы"
      }
    end
  end

  def destroy
    @user = User.find(params[:id])

    current_user.ignored_users.delete(@user)
    render json: {
      notice: "Сообщения от #{@user.nickname} больше не блокируются"
    }
  end
end

