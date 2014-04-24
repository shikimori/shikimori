class UserRatesController < ApplicationController
  load_and_authorize_resource

  def create
    # TODO: в user_rate добавить after_create колбек с записью в историю о добавлении в список
  end

  def update
  end

  def destroy
    # TODO: в user_rate добавить after_destroy колбек с записью в историю об удалении из списка
  end

  # очистка списка и истории
  def cleanup
    current_user.object.history.where(target_type: params[:type].capitalize).delete_all
    current_user.object.history.where(action: "mal_#{params[:type]}_import").delete_all
    current_user.object.history.where(action: "ap_#{params[:type]}_import").delete_all
    current_user.send("#{params[:type]}_rates").delete_all
    current_user.touch

    flash[:notice] = "Выполнена очистка вашего #{params[:type] == 'anime' ? 'аниме' : 'манги'} списка и вашей истории по #{params[:type] == 'anime' ? 'аниме' : 'манге'}"
    redirect_to user_url(current_user)
  end

  # сброс оценок в списке
  def reset
    current_user.send("#{params[:type]}_rates").update_all score: 0
    current_user.touch

    flash[:notice] = "Выполнен сброс оценок в вашем #{params[:type] == 'anime' ? 'аниме' : 'манги'} списке"
    redirect_to user_url(current_user)
  end

private
  def user_rate_params
    params
      .require(:user_rate)
      .permit(:status, :episodes, :chapters, :volumes, :score, :notice, :rewatches)
  end
end
