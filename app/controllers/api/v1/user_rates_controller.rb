class Api::V1::UserRatesController < Api::V1::ApiController
  load_and_authorize_resource

  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, "/user_rates", "Create an user rate"
  param :user_rate, Hash do
    param :chapters, :undef
    param :episodes, :undef
    param :notice, :undef
    param :rewatches, :undef
    param :score, :undef
    param :status, :undef
    param :target_id, :number
    param :target_type, :undef
    param :user_id, :number
    param :volumes, :undef
  end
  def create
    @user_rate.save
    respond_with @user_rate, location: nil
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PATCH, "/user_rates/:id", "Update an user rate"
  api :PUT, "/user_rates/:id", "Update an user rate"
  param :user_rate, Hash do
    param :chapters, :undef
    param :episodes, :undef
    param :notice, :undef
    param :rewatches, :undef
    param :score, :undef
    param :status, :undef
    param :volumes, :undef
  end
  def update
    @user_rate.update update_params
    respond_with @user_rate, location: nil
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, "/user_rates/:id", "Destroy an user rate"
  def destroy
    # TODO: в user_rate добавить after_destroy колбек с записью в историю об удалении из списка
    @user_rate.destroy
    respond_with @user_rate, location: nil
  end

  # очистка списка и истории
  api :DELETE, "/user_rates/:type/cleanup", "Delete entire user rates and history"
  error :code => 302
  def cleanup
    current_user.object.history.where(target_type: params[:type].capitalize).delete_all
    current_user.object.history.where(action: "mal_#{params[:type]}_import").delete_all
    current_user.object.history.where(action: "ap_#{params[:type]}_import").delete_all
    current_user.send("#{params[:type]}_rates").delete_all
    current_user.touch

    redirect_to user_url(current_user), notice: "Выполнена очистка вашего #{params[:type] == 'anime' ? 'аниме' : 'манги'} списка и вашей истории по #{params[:type] == 'anime' ? 'аниме' : 'манге'}"
  end

  # сброс оценок в списке
  api :DELETE, "/user_rates/:type/reset", "Reset all user scores to 0"
  error :code => 302
  def reset
    current_user.send("#{params[:type]}_rates").update_all score: 0
    current_user.touch

    redirect_to user_url(current_user), notice: "Выполнен сброс оценок в вашем #{params[:type] == 'anime' ? 'аниме' : 'манги'} списке"
  end

private
  def create_params
    params
      .require(:user_rate)
      .permit(:target_id, :target_type, :user_id, :status, :episodes, :chapters, :volumes, :score, :notice, :rewatches)
  end

  def update_params
    params
      .require(:user_rate)
      .permit(:status, :episodes, :chapters, :volumes, :score, :notice, :rewatches)
  end
end
