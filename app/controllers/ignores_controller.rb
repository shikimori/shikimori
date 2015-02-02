class IgnoresController < ShikimoriController
  before_filter :authenticate_user!

  def create
    @target_user = User.find(params[:id])
    current_user.ignores.create!(target: @target_user) unless current_user.ignores?(@target_user)
    render json: { notice: "Сообщения от #{@target_user.nickname} заблокированы" }
  end

  def destroy
    @user = User.find(params[:id])
    current_user.ignored_users.delete(@user)
    render json: { notice: "Сообщения от #{@user.nickname} больше не блокируются" }
  end
end

