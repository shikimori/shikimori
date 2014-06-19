class SubscriptionsController < ShikimoriController
  before_filter :authenticate_user!

  def create
    target = params[:type].constantize.find params[:id]
    current_user.subscribe target

    render json: { notice: 'Вы подписались на этот топик', method: 'delete' }
  end

  def destroy
    target = params[:type].constantize.find params[:id]
    current_user.unsubscribe target

    render json: { notice: 'Вы отписались от этого топика', method: 'post' }
  end
end
