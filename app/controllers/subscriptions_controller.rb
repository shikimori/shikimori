class SubscriptionsController < ApplicationController
  def create
    raise Unauthorized unless user_signed_in?

    target = Object.const_get(params[:type]).find(params[:id])
    current_user.subscribe(target)

    render json: {
      notice: 'Вы подписались на этот топик',
      method: 'delete'
    }
  end

  def destroy
    raise Unauthorized unless user_signed_in?

    target = Object.const_get(params[:type]).find(params[:id])
    current_user.unsubscribe(target)

    render json: {
      notice: 'Вы отписались от этого топика',
      method: 'post'
    }
  end
end
