class Api::V1::IgnoresController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/ignores/:id', 'Create an ignore'
  def create
    @target_user = User.find(params[:id])
    current_user.ignores.create!(target: @target_user) unless current_user.ignores?(@target_user)
    render json: { notice: "Сообщения от #{@target_user.nickname} заблокированы" }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/ignores/:id', 'Destroy an ignore'
  def destroy
    @user = User.find(params[:id])
    current_user.ignored_users.delete(@user)
    render json: { notice: "Сообщения от #{@user.nickname} больше не блокируются" }
  end
end

