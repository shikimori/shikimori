class Api::V1::IgnoresController < Api::V1::ApiController
  before_filter :authenticate_user!

  api :POST, '/ignores/:id', 'Create an ignore', deprecated: true
  def create
    @target_user = User.find(params[:id])
    current_user.ignores.create!(target: @target_user) unless current_user.ignores?(@target_user)
    render json: { notice: i18n_t('ignored', nickname: @target_user.nickname) }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/ignores/:id', 'Destroy an ignore', deprecated: true
  def destroy
    @user = User.find(params[:id])
    current_user.ignored_users.delete(@user)
    render json: { notice: i18n_t('not_ignored', nickname: @user.nickname) }
  end
end

